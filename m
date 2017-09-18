From: Richard Cochran <rcochran@linutronix.de>
Subject: [PATCH RFC V1 net-next 2/6] net: skbuff: Add a field to support time based transmission.
Date: Mon, 18 Sep 2017 09:41:17 +0200
Message-ID: <555939002f1ca9d89b14f30b3579445e4fa628d9.1505719061.git.rcochran@linutronix.de>
References: <cover.1505719061.git.rcochran@linutronix.de>
Cc: <linux-kernel@vger.kernel.org>, intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <rcochran@linutronix.de>
---
 include/linux/skbuff.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef00061..bc7f7dcbb413 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -635,6 +635,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@dst_pending_confirm: need to confirm neighbour
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
+ *	@transmit_time: desired future transmission time in nanoseconds
  *	@mark: Generic packet mark
  *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
@@ -804,6 +805,7 @@ struct sk_buff {
 #ifdef CONFIG_NETWORK_SECMARK
 	__u32		secmark;
 #endif
+	__u64			transmit_time;
 
 	union {
 		__u32		mark;
-- 
2.11.0

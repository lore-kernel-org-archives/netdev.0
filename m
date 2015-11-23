From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 01/10] hv_netvsc: Resize some of the variables in
 hv_netvsc_packet
Date: Mon, 23 Nov 2015 15:28:57 -0800
Message-ID: <1448321346-21357-1-git-send-email-kys@microsoft.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448321324-21318-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

As part of reducing the size of the hv_netvsc_packet, resize some of the
variables based on their usage.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 5fa98f5..972e562 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -127,11 +127,11 @@ struct ndis_tcp_ip_checksum_info;
  */
 struct hv_netvsc_packet {
 	/* Bookkeeping stuff */
-	u32 status;
+	u8 status;
 
-	bool is_data_pkt;
-	bool xmit_more; /* from skb */
-	bool cp_partial; /* partial copy into send buffer */
+	u8 is_data_pkt;
+	u8 xmit_more; /* from skb */
+	u8 cp_partial; /* partial copy into send buffer */
 
 	u16 vlan_tci;
 
@@ -147,13 +147,13 @@ struct hv_netvsc_packet {
 	/* This points to the memory after page_buf */
 	struct rndis_message *rndis_msg;
 
-	u32 rmsg_size; /* RNDIS header and PPI size */
-	u32 rmsg_pgcnt; /* page count of RNDIS header and PPI */
+	u8 rmsg_size; /* RNDIS header and PPI size */
+	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
 
 	u32 total_data_buflen;
 	/* Points to the send/receive buffer where the ethernet frame is */
 	void *data;
-	u32 page_buf_cnt;
+	u8 page_buf_cnt;
 	struct hv_page_buffer *page_buf;
 };
 
-- 
1.7.4.1

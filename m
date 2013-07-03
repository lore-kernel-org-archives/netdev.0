From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next] net: lls fix build with allnoconfig
Date: Wed, 03 Jul 2013 06:41:24 +0300
Message-ID: <20130703034124.28666.55448.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

correct placeholder declarations to prevent build breakage when
!CONFIG_NET_LL_RX_POLL

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/ll_poll.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index b76f004..0d620ba 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -163,12 +163,12 @@ static inline unsigned long ll_get_flag(void)
 	return 0;
 }
 
-static inline u64 sk_ll_end_time(struct sock *sk)
+static inline u64 ll_start_time(unsigned int flag)
 {
 	return 0;
 }
 
-static inline u64 ll_end_time(void)
+static inline u64 ll_run_time(void)
 {
 	return 0;
 }
@@ -191,7 +191,7 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 {
 }
 
-static inline bool can_poll_ll(u64 end_time)
+static inline bool can_poll_ll(u64 start_time, u64 run_time)
 {
 	return false;
 }

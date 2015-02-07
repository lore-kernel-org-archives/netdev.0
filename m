From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch errors
Date: Sat,  7 Feb 2015 18:06:33 +0100
Message-ID: <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following checkpatch errors:
	1. trailing statement
	1. assignment of variable in if condition
	1. incorrectly placed brace after function definition

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/act2000/capi.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
index 3f66ca2..5d677e6 100644
--- a/drivers/isdn/act2000/capi.c
+++ b/drivers/isdn/act2000/capi.c
@@ -113,7 +113,8 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
 			m->hdr.cmd.cmd = c;			\
 			m->hdr.cmd.subcmd = s;			\
 			m->hdr.msgnum = actcapi_nextsmsg(card); \
-		} else m = NULL;				\
+		} else
+			m = NULL;				\
 	}
 
 #define ACTCAPI_CHKSKB if (!skb) {					\
@@ -563,7 +564,8 @@ actcapi_data_b3_ind(act2000_card *card, struct sk_buff *skb) {
 	blocknr = msg->msg.data_b3_ind.blocknr;
 	skb_pull(skb, 19);
 	card->interface.rcvcallb_skb(card->myid, chan, skb);
-	if (!(skb = alloc_skb(11, GFP_ATOMIC))) {
+	skb = alloc_skb(11, GFP_ATOMIC);
+	if (!skb) {
 		printk(KERN_WARNING "actcapi: alloc_skb failed\n");
 		return 1;
 	}
@@ -990,7 +992,8 @@ actcapi_debug_dlpd(actcapi_dlpd *dlpd)
 }
 
 #ifdef DEBUG_DUMP_SKB
-static void dump_skb(struct sk_buff *skb) {
+static void dump_skb(struct sk_buff *skb)
+{
 	char tmp[80];
 	char *p = skb->data;
 	char *t = tmp;
-- 
2.1.0

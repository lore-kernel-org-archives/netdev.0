From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 5/7] drivers: isdn: act2000: module.c: remove parenthesres around return values.
Date: Sat,  7 Feb 2015 20:05:27 +0100
Message-ID: <1423335929-24926-6-git-send-email-baspeters93@gmail.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

return is not a function, therefore parentheses are not needed.
---
 drivers/isdn/act2000/module.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index 9359b36..889ffcb 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -111,7 +111,7 @@ act2000_find_eaz(act2000_card *card, char eaz)
 
 	while (p) {
 		if (p->eaz == eaz)
-			return (p->msn);
+			return p->msn;
 		p = p->next;
 	}
 	return ("\0");
@@ -293,7 +293,7 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 			if (ret)
 				return ret;
 			if (card->flags & ACT2000_FLAGS_RUNNING)
-				return (actcapi_manufacturer_req_msn(card));
+				return actcapi_manufacturer_req_msn(card);
 			return 0;
 		case ACT2000_IOCTL_ADDCARD:
 			if (copy_from_user(&cdef, arg,
@@ -520,7 +520,7 @@ if_command(isdn_ctrl *c)
 	act2000_card *card = act2000_findcard(c->driver);
 
 	if (card)
-		return (act2000_command(card, c));
+		return act2000_command(card, c);
 	printk(KERN_ERR
 	       "act2000: if_command %d called with invalid driverId %d!\n",
 	       c->command, c->driver);
@@ -535,7 +535,7 @@ if_writecmd(const u_char __user *buf, int len, int id, int channel)
 	if (card) {
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		return (len);
+		return len;
 	}
 	printk(KERN_ERR
 	       "act2000: if_writecmd called with invalid driverId!\n");
@@ -550,7 +550,7 @@ if_readstatus(u_char __user *buf, int len, int id, int channel)
 	if (card) {
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		return (act2000_readstatus(buf, len, card));
+		return act2000_readstatus(buf, len, card);
 	}
 	printk(KERN_ERR
 	       "act2000: if_readstatus called with invalid driverId!\n");
@@ -565,7 +565,7 @@ if_sendbuf(int id, int channel, int ack, struct sk_buff *skb)
 	if (card) {
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		return (act2000_sendbuf(card, channel, ack, skb));
+		return act2000_sendbuf(card, channel, ack, skb);
 	}
 	printk(KERN_ERR
 	       "act2000: if_sendbuf called with invalid driverId!\n");
-- 
2.1.0

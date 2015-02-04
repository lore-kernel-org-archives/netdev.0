From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 3/3] drivers: isdn: isdnloop: isdnloop.c: Remove parenthesis around return values, as specified in CodingStyle.
Date: Wed,  4 Feb 2015 23:33:01 +0100
Message-ID: <1423089181-15850-4-git-send-email-baspeters93@gmail.com>
References: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/isdnloop/isdnloop.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index e4d3620..ef9c8e4 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -552,9 +552,9 @@ isdnloop_unicause(isdnloop_card *card, int loc, int cau)
 		sprintf(buf, "%02X44", ctable_1t[cau]);
 		break;
 	default:
-		return ("0000");
+		return "0000";
 	}
-	return (buf);
+	return buf;
 }
 
 /*
@@ -750,17 +750,17 @@ isdnloop_vstphone(isdnloop_card *card, char *phone, int caller)
 		if (caller) {
 			for (i = 0; i < 2; i++)
 				if (!(strcmp(card->s0num[i], phone)))
-					return (phone);
-			return (card->s0num[0]);
+					return phone;
+			return card->s0num[0];
 		}
-		return (phone);
+		return phone;
 		break;
 	case ISDN_PTYPE_1TR6:
 		if (caller) {
 			sprintf(nphone, "%s%c", card->s0num[0], phone[0]);
-			return (nphone);
+			return nphone;
 		} else
-			return (&phone[strlen(phone) - 1]);
+			return &phone[strlen(phone) - 1];
 		break;
 	}
 	return "";
@@ -1144,14 +1144,14 @@ isdnloop_command(isdn_ctrl *c, isdnloop_card *card)
 		case ISDNLOOP_IOCTL_STARTUP:
 			if (!access_ok(VERIFY_READ, (void *) a, sizeof(isdnloop_sdef)))
 				return -EFAULT;
-			return (isdnloop_start(card, (isdnloop_sdef *) a));
+			return isdnloop_start(card, (isdnloop_sdef *) a);
 			break;
 		case ISDNLOOP_IOCTL_ADDCARD:
 			if (copy_from_user((char *)&cdef,
 					   (char *)a,
 					   sizeof(cdef)))
 				return -EFAULT;
-			return (isdnloop_addcard(cdef.id1));
+			return isdnloop_addcard(cdef.id1);
 			break;
 		case ISDNLOOP_IOCTL_LEASEDCFG:
 			if (a) {
@@ -1373,7 +1373,7 @@ if_command(isdn_ctrl *c)
 	isdnloop_card *card = isdnloop_findcard(c->driver);
 
 	if (card)
-		return (isdnloop_command(c, card));
+		return isdnloop_command(c, card);
 	printk(KERN_ERR
 	       "isdnloop: if_command called with invalid driverId!\n");
 	return -ENODEV;
@@ -1387,7 +1387,7 @@ if_writecmd(const u_char __user *buf, int len, int id, int channel)
 	if (card) {
 		if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 			return -ENODEV;
-		return (isdnloop_writecmd(buf, len, 1, card));
+		return isdnloop_writecmd(buf, len, 1, card);
 	}
 	printk(KERN_ERR
 	       "isdnloop: if_writecmd called with invalid driverId!\n");
@@ -1402,7 +1402,7 @@ if_readstatus(u_char __user *buf, int len, int id, int channel)
 	if (card) {
 		if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 			return -ENODEV;
-		return (isdnloop_readstatus(buf, len, card));
+		return isdnloop_readstatus(buf, len, card);
 	}
 	printk(KERN_ERR
 	       "isdnloop: if_readstatus called with invalid driverId!\n");
@@ -1419,7 +1419,7 @@ if_sendbuf(int id, int channel, int ack, struct sk_buff *skb)
 			return -ENODEV;
 		/* ack request stored in skb scratch area */
 		*(skb->head) = ack;
-		return (isdnloop_sendbuf(channel, skb, card));
+		return isdnloop_sendbuf(channel, skb, card);
 	}
 	printk(KERN_ERR
 	       "isdnloop: if_sendbuf called with invalid driverId!\n");
@@ -1499,7 +1499,7 @@ static int __init
 isdnloop_init(void)
 {
 	if (isdnloop_id)
-		return (isdnloop_addcard(isdnloop_id));
+		return isdnloop_addcard(isdnloop_id);
 
 	return 0;
 }
-- 
2.1.0

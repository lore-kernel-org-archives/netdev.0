From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 4/12] Host AP: Remove ioctl debug messages
Date: Sun, 7 Nov 2004 23:12:42 -0800
Message-ID: <20041108071242.GE1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove debug message from unsupported ioctls. Some of common ioctls
triggered these (e.g., SIOCGMIIPHY, SIOCGMIIREG, SIOCSMIIREG,
SIOCDEVPRIVATE) and filled debug logs with unwanted messages.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-07 22:38:18 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-07 22:38:18 -08:00
@@ -3452,14 +3452,6 @@
 		break;
 
 	default:
-		if (cmd >= SIOCSIWCOMMIT && cmd <= SIOCGIWPOWER) {
-			/* unsupport wireless extensions get through here - do
-			 * not report these to debug log */
-			ret = -EOPNOTSUPP;
-			break;
-		}
-		printk(KERN_DEBUG "%s unsupported ioctl(0x%04x)\n",
-		       dev->name, cmd);
 		ret = -EOPNOTSUPP;
 		break;
 	}

-- 
Jouni Malinen                                            PGP id EFC895FA

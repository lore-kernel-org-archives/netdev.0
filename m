From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/5) irlap hashbin can be private
Date: Fri, 15 Aug 2003 15:57:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815155729.06632ade.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

irlap hashbin is only used in one file, so make it private not global.

diff -Nru a/include/net/irda/irlap.h b/include/net/irda/irlap.h
--- a/include/net/irda/irlap.h	Fri Aug 15 13:52:21 2003
+++ b/include/net/irda/irlap.h	Fri Aug 15 13:52:21 2003
@@ -208,8 +208,6 @@
 	int    next_bofs;     /* Negotiated extra BOFs after next frame */
 };
 
-extern hashbin_t *irlap;
-
 /* 
  *  Function prototypes 
  */
diff -Nru a/net/irda/irlap.c b/net/irda/irlap.c
--- a/net/irda/irlap.c	Fri Aug 15 13:52:21 2003
+++ b/net/irda/irlap.c	Fri Aug 15 13:52:21 2003
@@ -48,7 +48,7 @@
 #include <net/irda/timer.h>
 #include <net/irda/qos.h>
 
-hashbin_t *irlap = NULL;
+static hashbin_t *irlap = NULL;
 int sysctl_slot_timeout = SLOT_TIMEOUT * 1000 / HZ;
 
 /* This is the delay of missed pf period before generating an event

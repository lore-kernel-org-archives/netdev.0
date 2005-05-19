From: jamal <hadi@cyberus.ca>
Subject: patch: small fixup
Date: Wed, 18 May 2005 20:36:10 -0400
Message-ID: <1116462970.6240.9.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-dgQoTPmSywBqbDRi7eEX"
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-dgQoTPmSywBqbDRi7eEX
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


My first git patch (dangerously knowledgeable after 30 minutes of
snorting blobs;->) against net-2.6.git. Consider this an excuse to send
a git patch ;->

--
Fixup simple action define to be consistent with other net/sched files

Signed-off-by: Jamal Hadi Salim

cheers,
jamal


--=-dgQoTPmSywBqbDRi7eEX
Content-Disposition: attachment; filename=act_g.p
Content-Type: text/x-pascal; name=act_g.p; charset=UTF-8
Content-Transfer-Encoding: 7bit

include/net/act_generic.h: needs update
Index: include/net/act_generic.h
===================================================================
--- 999772bc591650ab8b58d2c7a225ae83ecb6697f/include/net/act_generic.h  (mode:100644)
+++ uncommitted/include/net/act_generic.h  (mode:100644)
@@ -2,8 +2,8 @@
  * include/net/act_generic.h
  *
 */
-#ifndef ACT_GENERIC_H
-#define ACT_GENERIC_H
+#ifndef _NET_ACT_GENERIC_H
+#define _NET_ACT_GENERIC_H
 static inline int tcf_defact_release(struct tcf_defact *p, int bind)
 {
 	int ret = 0;

--=-dgQoTPmSywBqbDRi7eEX--

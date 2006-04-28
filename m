From: S P <speattle@yahoo.com>
Subject: [patch] cleanup unused macro in net/netlink/af_netlink.c
Date: Fri, 28 Apr 2006 13:51:43 -0700 (PDT)
Message-ID: <20060428205143.20727.qmail@web36613.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-771830371-1146257503=:20668"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web36613.mail.mud.yahoo.com ([209.191.85.30]:19310 "HELO
	web36613.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751801AbWD1Uvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 16:51:43 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0-771830371-1146257503=:20668
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Content-Id: 
Content-Disposition: inline

1 line removal, of unused macro.
ran 'egrep -r' from linux-2.6.16/ for Nprintk and
didn't see it anywhere else but here, in #define...

------------------------------------------------
signed off by: soyoung park<speattle@yahoo.com>
--0-771830371-1146257503=:20668
Content-Type: text/plain; name="remove_unused_macro.txt"
Content-Description: 1497678878-remove_unused_macro.txt
Content-Disposition: inline; filename="remove_unused_macro.txt"

--- linux-2.6.16/net/netlink/af_netlink.c~	Sun Mar 19 21:53:29 2006
+++ linux-2.6.16/net/netlink/af_netlink.c	Fri Apr 28 13:41:52 2006
@@ -61,7 +61,6 @@
 #include <net/scm.h>
 #include <net/netlink.h>
 
-#define Nprintk(a...)
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 
 struct netlink_sock {

--0-771830371-1146257503=:20668--

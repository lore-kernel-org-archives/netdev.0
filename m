From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] MODULE_ALIAS_PROTO for PPPoE
Date: Wed, 10 Dec 2003 10:22:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210102256.27d2ff51.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Rusty Russell
 <rusty@rustcorp.com.au>,
        Michal Ostrowski <mostrows@styk.uwaterloo.ca.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rusty added module aliases for most protocol families but missed this one.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1534  -> 1.1535 
#	 drivers/net/pppoe.c	1.37    -> 1.38   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/10	shemminger@osdl.org	1.1535
# Add module alias for pppoe
# --------------------------------------------
#
diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Wed Dec 10 10:20:36 2003
+++ b/drivers/net/pppoe.c	Wed Dec 10 10:20:36 2003
@@ -1151,3 +1151,4 @@
 MODULE_AUTHOR("Michal Ostrowski <mostrows@speakeasy.net>");
 MODULE_DESCRIPTION("PPP over Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_PPPOX);

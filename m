From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] fix sctp printk parameter types
Date: Wed, 27 Aug 2003 22:04:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827220431.2e1e7826.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply.

patch_name:	sctp_sizes.patch
patch_version:	2003-08-27.18:18:12
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	sctp: fix printk parameter type (gcc warning);
product:	Linux
product_versions: 260-test4
maintainer:	sri@us.ibm.com

diff -Naur ./net/sctp/socket.c~sctpsize ./net/sctp/socket.c
--- ./net/sctp/socket.c~sctpsize	Fri Aug 22 17:03:25 2003
+++ ./net/sctp/socket.c	Wed Aug 27 10:35:06 2003
@@ -852,7 +852,7 @@
 		associd = sinfo->sinfo_assoc_id;
 	}
 
-	SCTP_DEBUG_PRINTK("msg_len: %Zd, sinfo_flags: 0x%x\n",
+	SCTP_DEBUG_PRINTK("msg_len: %d, sinfo_flags: 0x%x\n",
 			  msg_len, sinfo_flags);
 
 	/* MSG_EOF or MSG_ABORT cannot be set on a TCP-style socket. */

--
~Randy

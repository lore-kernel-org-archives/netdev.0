From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test5 SEQ_START_TOKEN include/net/* [2/3]
Date: Tue, 09 Sep 2003 16:06:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063148799.603.72.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN linux-2.6.0-test5/include/net/rose.h SEQ_START_TOKEN_5/include/net/rose.h
--- linux-2.6.0-test5/include/net/rose.h	2003-09-08 12:49:53.000000000 -0700
+++ SEQ_START_TOKEN_5/include/net/rose.h	2003-09-09 11:31:45.000000000 -0700
@@ -140,9 +140,6 @@
 
 #define rose_sk(__sk) ((rose_cb *)(__sk)->sk_protinfo)
 
-/* Magic value indicating first entry in /proc (ie header) */
-#define ROSE_PROC_START ((void *) 1)
-
 /* af_rose.c */
 extern ax25_address rose_callsign;
 extern int  sysctl_rose_restart_request_timeout;

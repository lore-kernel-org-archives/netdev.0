From: davej@redhat.com
Subject: [PATCH] Duplicate access_ok in sunrpc
Date: Mon, 11 Aug 2003 17:48:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E19mFqr-00068W-00@tetrachloride>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Already checked some lines above.

diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/sunrpc/sysctl.c linux-2.5/net/sunrpc/sysctl.c
--- bk-linus/net/sunrpc/sysctl.c	2003-06-30 14:01:04.000000000 +0100
+++ linux-2.5/net/sunrpc/sysctl.c	2003-06-30 16:04:03.000000000 +0100
@@ -102,7 +102,7 @@ proc_dodebug(ctl_table *table, int write
 		len = sprintf(tmpbuf, "%d", *(unsigned int *) table->data);
 		if (len > left)
 			len = left;
-		copy_to_user(buffer, tmpbuf, len);
+		__copy_to_user(buffer, tmpbuf, len);
 		if ((left -= len) > 0) {
 			put_user('\n', (char *)buffer + len);
 			left--;

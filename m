From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/13) atalk_proc whitespace in header
Date: Fri, 29 Aug 2003 13:55:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829135547.142856e4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The header for /proc/net/atalk/interfaces is not lined up right
with the data because it has a tab rather than spaces.

diff -Nru a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
--- a/net/appletalk/atalk_proc.c	Fri Aug 29 11:02:59 2003
+++ b/net/appletalk/atalk_proc.c	Fri Aug 29 11:02:59 2003
@@ -64,7 +64,7 @@
 	struct atalk_iface *iface;
 
 	if (v == (void *)1) {
-		seq_puts(seq, "Interface	  Address   Networks   "
+		seq_puts(seq, "Interface        Address   Networks  "
 			      "Status\n");
 		goto out;
 	}

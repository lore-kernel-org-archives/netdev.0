From: Ravikiran G Thirumalai <kiran@in.ibm.com>
Subject: [trivial] Use __init and __exit for sctp_init and sctp_exit
Date: Tue, 10 Dec 2002 18:55:02 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021210185502.G17375@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller " <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

These module_init and module_exit routines should have been marked 
__init and __exit like every where else I guess... 

Please apply

Thanks,
Kiran


diff -ruN -X dontdiff linux-2.5.51/net/sctp/protocol.c sctp_fix-2.5.51/net/sctp/protocol.c
--- linux-2.5.51/net/sctp/protocol.c	Tue Dec 10 08:16:10 2002
+++ sctp_fix-2.5.51/net/sctp/protocol.c	Tue Dec 10 18:48:07 2002
@@ -598,7 +598,7 @@
 }
 
 /* Initialize the universe into something sensible.  */
-int sctp_init(void)
+int __init sctp_init(void)
 {
 	int i;
 	int status = 0;
@@ -751,7 +751,7 @@
 }
 
 /* Exit handler for the SCTP protocol.  */
-void sctp_exit(void)
+void __exit sctp_exit(void)
 {
 	/* BUG.  This should probably do something useful like clean
 	 * up all the remaining associations and all that memory.

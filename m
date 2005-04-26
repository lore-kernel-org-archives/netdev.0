From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2.6 1/6][SCTP] Fix SCTP_ASSOCINFO getsockopt for 1-1 style
 sockets.
Date: Tue, 26 Apr 2005 11:32:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504261114390.6387@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

I am resubmitting SCTP patches pine after fixing the leading space problem.
Please apply.

Thanks
Sridhar

[SCTP] Fix SCTP_ASSOCINFO getsockopt for 1-1 style sockets.

Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
----------------------------------------------------------------------
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2005-04-21 16:20:07 -07:00
+++ b/net/sctp/socket.c	2005-04-21 16:20:07 -07:00
@@ -3473,7 +3473,7 @@
 		return -EINVAL;

 	/* Values correspoinding to the specific association */
-	if (assocparams.sasoc_assoc_id != 0) {
+	if (asoc) {
 		assocparams.sasoc_asocmaxrxt = asoc->max_retrans;
 		assocparams.sasoc_peer_rwnd = asoc->peer.rwnd;
 		assocparams.sasoc_local_rwnd = asoc->a_rwnd;

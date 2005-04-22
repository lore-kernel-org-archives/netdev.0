From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH][SCTP] Fix SCTP_ASSOCINFO getsockopt for 1-1 style sockets
Date: Fri, 22 Apr 2005 12:28:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504221211470.5192@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please apply to 2.6.

Thanks
Sridhar
=======================================================================
[SCTP] Fix SCTP_ASSOCINFO getsockopt for 1-1 style sockets.

Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
========================================================================
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

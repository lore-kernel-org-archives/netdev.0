From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  7/12] Reformat ax25_proto_ops initialization
Date: Sun, 11 Sep 2005 23:19:17 +0100
Message-ID: <20050911221917.GA9315@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reformat iniitalization of ax25_proto_ops.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/ax25/af_ax25.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

Index: net-2.6.git/net/ax25/af_ax25.c
===================================================================
--- net-2.6.git.orig/net/ax25/af_ax25.c
+++ net-2.6.git/net/ax25/af_ax25.c
@@ -1947,24 +1947,24 @@ static struct net_proto_family ax25_fami
 };
 
 static struct proto_ops ax25_proto_ops = {
-	.family =	PF_AX25,
-	.owner =	THIS_MODULE,
-	.release =	ax25_release,
-	.bind =		ax25_bind,
-	.connect =	ax25_connect,
-	.socketpair =	sock_no_socketpair,
-	.accept =	ax25_accept,
-	.getname =	ax25_getname,
-	.poll =		datagram_poll,
-	.ioctl =	ax25_ioctl,
-	.listen =	ax25_listen,
-	.shutdown =	ax25_shutdown,
-	.setsockopt =	ax25_setsockopt,
-	.getsockopt =	ax25_getsockopt,
-	.sendmsg =	ax25_sendmsg,
-	.recvmsg =	ax25_recvmsg,
-	.mmap =		sock_no_mmap,
-	.sendpage =	sock_no_sendpage,
+	.family		= PF_AX25,
+	.owner		= THIS_MODULE,
+	.release	= ax25_release,
+	.bind		= ax25_bind,
+	.connect	= ax25_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= ax25_accept,
+	.getname	= ax25_getname,
+	.poll		= datagram_poll,
+	.ioctl		= ax25_ioctl,
+	.listen		= ax25_listen,
+	.shutdown	= ax25_shutdown,
+	.setsockopt	= ax25_setsockopt,
+	.getsockopt	= ax25_getsockopt,
+	.sendmsg	= ax25_sendmsg,
+	.recvmsg	= ax25_recvmsg,
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage,
 };
 
 /*

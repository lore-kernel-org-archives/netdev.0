From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] sctp/socket: fix printk arg. type
Date: Mon, 15 Nov 2004 11:42:34 -0800
Message-ID: <419906AA.8010705@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090302010609050607090804"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, sri@us.ibm.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090302010609050607090804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

fix printk argument type warning:
net/sctp/socket.c:2672: warning: format argument is not a pointer (arg 5)

diffstat:=
   net/sctp/socket.c |    2 +-
   1 files changed, 1 insertion(+), 1 deletion(-)

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
-- 


--------------090302010609050607090804
Content-Type: text/x-patch;
 name="socket_printk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="socket_printk.patch"

diff -Naurp ./net/sctp/socket.c~socket_printk ./net/sctp/socket.c
--- ./net/sctp/socket.c~socket_printk	2004-11-15 10:02:01.901678280 -0800
+++ ./net/sctp/socket.c	2004-11-15 10:56:53.683251416 -0800
@@ -2669,7 +2669,7 @@ static int sctp_getsockopt_sctp_status(s
 		goto out;
 	}
 
-	SCTP_DEBUG_PRINTK("sctp_getsockopt_sctp_status(%d): %d %d %p\n",
+	SCTP_DEBUG_PRINTK("sctp_getsockopt_sctp_status(%d): %d %d %d\n",
 			  len, status.sstat_state, status.sstat_rwnd,
 			  status.sstat_assoc_id);
 


--------------090302010609050607090804--

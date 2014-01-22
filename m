From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] net: update comments of "struct msghdr" with the more accurate RFC3542 ones
Date: Wed, 22 Jan 2014 05:39:46 +0100
Message-ID: <1390365586-4149-1-git-send-email-fx.lebail@yahoo.com>
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:42348 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaAVFA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 00:00:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
 include/linux/socket.h |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5d488a6..8e98297 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -45,13 +45,13 @@ struct linger {
  */
  
 struct msghdr {
-	void	*	msg_name;	/* Socket name			*/
-	int		msg_namelen;	/* Length of name		*/
-	struct iovec *	msg_iov;	/* Data blocks			*/
-	__kernel_size_t	msg_iovlen;	/* Number of blocks		*/
-	void 	*	msg_control;	/* Per protocol magic (eg BSD file descriptor passing) */
-	__kernel_size_t	msg_controllen;	/* Length of cmsg list */
-	unsigned int	msg_flags;
+	void		*msg_name;	/* ptr to socket address structure */
+	int		msg_namelen;	/* size of socket address structure */
+	struct iovec	*msg_iov;	/* scatter/gather array */
+	__kernel_size_t	msg_iovlen;	/* # elements in msg_iov */
+	void		*msg_control;	/* ancillary data */
+	__kernel_size_t	msg_controllen;	/* ancillary data buffer length */
+	unsigned int	msg_flags;	/* flags on received message */
 };
 
 /* For recvmmsg/sendmmsg */
-- 
1.7.10.4

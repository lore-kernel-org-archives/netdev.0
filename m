From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK]: Remove references to process ID
Date: Sat, 5 May 2007 15:33:43 +1000
Message-ID: <20070505053343.GA17499@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1174 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755448AbXEEFds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 01:33:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NETLINK]: Remove references to process ID

People treating the *_pid fields in netlink as a process ID has caused
endless confusion over the years.  The fact that our own netlink.h
does this only adds to the confusion.

So here is a patch to change the comments to refer to it as the port
ID which hopefully will make it clear what the purpose of the fields
really is.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f41688f..2e23353 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -31,7 +31,7 @@ struct sockaddr_nl
 {
 	sa_family_t	nl_family;	/* AF_NETLINK	*/
 	unsigned short	nl_pad;		/* zero		*/
-	__u32		nl_pid;		/* process pid	*/
+	__u32		nl_pid;		/* port ID	*/
        	__u32		nl_groups;	/* multicast groups mask */
 };
 
@@ -41,7 +41,7 @@ struct nlmsghdr
 	__u16		nlmsg_type;	/* Message content */
 	__u16		nlmsg_flags;	/* Additional flags */
 	__u32		nlmsg_seq;	/* Sequence number */
-	__u32		nlmsg_pid;	/* Sending process PID */
+	__u32		nlmsg_pid;	/* Sending process port ID */
 };
 
 /* Flags values */

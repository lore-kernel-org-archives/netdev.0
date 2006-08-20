From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Make struct sockaddr_in::sin_port __be16
Date: Mon, 21 Aug 2006 03:21:24 +0400
Message-ID: <20060820232124.GC5208@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:59169 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932074AbWHTXVh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 19:21:37 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1754823nfa
        for <netdev@vger.kernel.org>; Sun, 20 Aug 2006 16:21:35 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/in.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -177,7 +177,7 @@ struct in_pktinfo
 #define __SOCK_SIZE__	16		/* sizeof(struct sockaddr)	*/
 struct sockaddr_in {
   sa_family_t		sin_family;	/* Address family		*/
-  unsigned short int	sin_port;	/* Port number			*/
+  __be16		sin_port;	/* Port number			*/
   struct in_addr	sin_addr;	/* Internet address		*/
 
   /* Pad to size of `struct sockaddr'. */


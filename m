From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Make struct in_addr::s_addr __be32
Date: Mon, 21 Aug 2006 03:20:51 +0400
Message-ID: <20060820232051.GB5208@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:7969 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932070AbWHTXVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 19:21:03 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1754758nfa
        for <netdev@vger.kernel.org>; Sun, 20 Aug 2006 16:21:02 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There will be relatively small increase in sparse endian warnings, but
this (and sin_port) patch is a first step to make networking code endian
clean.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/in.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -52,7 +52,7 @@ enum {
 
 /* Internet address. */
 struct in_addr {
-	__u32	s_addr;
+	__be32	s_addr;
 };
 
 #define IP_TOS		1


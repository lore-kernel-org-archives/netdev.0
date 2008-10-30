From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: remove unused struct xfrm_policy::next
Date: Thu, 30 Oct 2008 12:44:59 +0300
Message-ID: <20081030094459.GB5742@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:29902 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbYJ3Jlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 05:41:40 -0400
Received: by ey-out-2122.google.com with SMTP id 6so174977eyi.37
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 02:41:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h |    1 -
 1 file changed, 1 deletion(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -479,7 +479,6 @@ struct xfrm_policy_walk {
 
 struct xfrm_policy
 {
-	struct xfrm_policy	*next;
 	struct hlist_node	bydst;
 	struct hlist_node	byidx;
 

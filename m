From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip monitor neigh: Change 'delete' to 'Deleted' to be consistent with ip route
Date: Thu, 15 Oct 2015 11:47:43 -0700
Message-ID: <1444934863-12704-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33063 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbJOSrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 14:47:48 -0400
Received: by pabrc13 with SMTP id rc13so95126637pab.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 11:47:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

It helps to grep for one string "Deleted" when monitoring all events.

Fixes: 6ea3ebafe077 ("iproute2: inform user when a neighbor is removed")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
I am not sure if it is too late for this change. But, sending this patch 
out because it only affects ip monitor output

 ip/ipneigh.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index a9e23f4..ce57ede 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -256,7 +256,7 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 
 	if (n->nlmsg_type == RTM_DELNEIGH)
-		fprintf(fp, "delete ");
+		fprintf(fp, "Deleted ");
 	else if (n->nlmsg_type == RTM_GETNEIGH)
 		fprintf(fp, "miss ");
 	if (tb[NDA_DST]) {
-- 
1.9.1

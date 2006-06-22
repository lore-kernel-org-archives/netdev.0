From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 10/32] [TIPC] Fixed privilege checking typo in dest_name_check().
Date: Thu, 22 Jun 2006 15:59:23 +0200
Message-ID: <11509847851684-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:27798 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030645AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch originated by Stephane Ouellette <ouellettes@videotron.ca>.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 648a734..eaf4d69 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -426,7 +426,7 @@ static int dest_name_check(struct sockad
 
         if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
 		return -EFAULT;
-	if ((ntohs(hdr.tcm_type) & 0xC000) & (!capable(CAP_NET_ADMIN)))
+	if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
 		return -EACCES;
         
 	return 0;
-- 
1.4.0


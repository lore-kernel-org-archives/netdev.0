From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next] net: xfrm: Change u32 sysctl entries to use proc_douintvec
Date: Tue,  6 Sep 2016 18:09:31 -0600
Message-ID: <1473206971-20131-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38208 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933652AbcIGAKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 20:10:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

proc_dointvec limits the values to INT_MAX in u32 sysctl entries.
proc_douintvec allows to write upto UINT_MAX.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/xfrm/xfrm_sysctl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05a6e3d..35a7e79 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -17,13 +17,13 @@ static struct ctl_table xfrm_table[] = {
 		.procname	= "xfrm_aevent_etime",
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_douintvec
 	},
 	{
 		.procname	= "xfrm_aevent_rseqth",
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_douintvec
 	},
 	{
 		.procname	= "xfrm_larval_drop",
-- 
1.9.1

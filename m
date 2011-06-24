From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/20] tipc: Correct typo in link statistics output
Date: Fri, 24 Jun 2011 18:07:19 -0400
Message-ID: <1308953247-25266-13-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34394 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756947Ab1FXWHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:50 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Fixes a minor error in the title of one of the message size profiling
values printed as part of TIPC's link statistics.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 5ed4b4f..5bfe000 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2882,7 +2882,7 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 		profile_total = 1;
 	tipc_printf(&pb, "  TX profile sample:%u packets  average:%u octets\n"
 			 "  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% "
-			 "-16354:%u%% -32768:%u%% -66000:%u%%\n",
+			 "-16384:%u%% -32768:%u%% -66000:%u%%\n",
 		    l_ptr->stats.msg_length_counts,
 		    l_ptr->stats.msg_lengths_total / profile_total,
 		    percent(l_ptr->stats.msg_length_profile[0], profile_total),
-- 
1.7.4.4


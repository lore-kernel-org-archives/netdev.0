From: Michele Baldessari <michele@acksyn.org>
Subject: [net-next 2/2] sctp: replace seq_printf with seq_puts
Date: Thu, 30 Oct 2014 10:29:16 +0100
Message-ID: <1414661356-17255-2-git-send-email-michele@acksyn.org>
References: <1414661356-17255-1-git-send-email-michele@acksyn.org>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Michele Baldessari <michele@acksyn.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:32792 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758524AbaJ3J3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 05:29:47 -0400
In-Reply-To: <1414661356-17255-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes checkpatch warning:
"WARNING: Prefer seq_puts to seq_printf"

Signed-off-by: Michele Baldessari <michele@acksyn.org>
---
 net/sctp/proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index bfb242af06ab..0697eda5aed8 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -490,14 +490,14 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 			 * Note: We don't have a way to tally this at the moment
 			 * so lets just leave it as zero for the moment
 			 */
-			seq_printf(seq, "0 ");
+			seq_puts(seq, "0 ");
 
 			/*
 			 * remote address start time (START).  This is also not
 			 * currently implemented, but we can record it with a
 			 * jiffies marker in a subsequent patch
 			 */
-			seq_printf(seq, "0 ");
+			seq_puts(seq, "0 ");
 
 			/*
 			 * The current state of this destination. I.e.
-- 
2.1.0

From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/4 net-2.6.26] [SCTP]: seq_printf format warning.
Date: Mon,  3 Mar 2008 18:48:42 +0300
Message-ID: <1204559323-19953-3-git-send-email-den@openvz.org>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59120 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755745AbYCCPsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 10:48:37 -0500
In-Reply-To: <1204559323-19953-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_association->hbinterval is unsigned long. Replace %8d with %8ld.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/sctp/proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 82bea30..138ab5f 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -325,7 +325,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq,
 			   "%8p %8p %-3d %-3d %-2d %-4d "
 			   "%4d %8d %8d %7d %5lu %-5d %5d "
-			   "%8d %5d %5d %4d %4d %4d %8d ",
+			   "%8ld %5d %5d %4d %4d %4d %8d ",
 			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
 			   assoc->state, hash,
 			   assoc->assoc_id,
-- 
1.5.3.rc5


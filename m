From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/16] tipc: Eliminate unused argument in print statement
Date: Tue, 11 May 2010 20:30:04 -0400
Message-ID: <9c230b0fd3fd7d55b59197888e1a3c3ac349dee4.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35212 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab0ELAaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:25 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UP7A000087
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:25 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate an argument in a print statement that has no corresponding
format specification.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 0b86f6a..c95038f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -3328,9 +3328,7 @@ static void link_print(struct link *l_ptr, struct print_buf *buf,
 		if (l_ptr->next_out)
 			tipc_printf(buf, "%u..",
 				    msg_seqno(buf_msg(l_ptr->next_out)));
-		tipc_printf(buf, "%u]",
-			    msg_seqno(buf_msg
-				      (l_ptr->last_out)), l_ptr->out_queue_size);
+		tipc_printf(buf, "%u]", msg_seqno(buf_msg(l_ptr->last_out)));
 		if ((mod(msg_seqno(buf_msg(l_ptr->last_out)) -
 			 msg_seqno(buf_msg(l_ptr->first_out)))
 		     != (l_ptr->out_queue_size - 1)) ||
-- 
1.7.1.rc2


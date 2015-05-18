From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 06/10] tc: gred: Print usage text if no arguments appear after "gred"
Date: Mon, 18 May 2015 11:35:10 -0400
Message-ID: <1431963314-56420-7-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-4.mit.edu ([18.9.25.15]:54864 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932245AbbERPfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:36 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is more helpful to the user, since the command takes two forms,
and the message that would otherwise appear about missing parameters
assumes one of those forms.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index a3dc722..65caeee 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -213,6 +213,10 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		argc--; argv++;
 	}
 
+	if (!ok) {
+		explain();
+		return -1;
+	}
 	if (!opt.qth_min || !opt.qth_max || !opt.limit || !avpkt ||
 	    (opt.DP<0)) {
 		fprintf(stderr, "Required parameter (min, max, limit, "
-- 
1.7.1

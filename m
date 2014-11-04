From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next] ipv6: trivial, add bracket for the if block
Date: Tue,  4 Nov 2014 23:01:00 +0100
Message-ID: <1415138460-24971-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:40154 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbaKDWIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:08:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "else" block is on several lines and use bracket.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 3dd7d4e..c143437 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -769,10 +769,10 @@ static void ip6fl_seq_stop(struct seq_file *seq, void *v)
 static int ip6fl_seq_show(struct seq_file *seq, void *v)
 {
 	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
-	if (v == SEQ_START_TOKEN)
+	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
 			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
-	else {
+	} else {
 		struct ip6_flowlabel *fl = v;
 		seq_printf(seq,
 			   "%05X %-1d %-6d %-6d %-6ld %-8ld %pi6 %-4d\n",
-- 
2.1.1

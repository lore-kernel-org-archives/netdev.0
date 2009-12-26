From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: XFRM: Fix spelling of neighbour.
Date: Sat, 26 Dec 2009 10:30:02 +0100
Message-ID: <20091226093002.GA5021@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:57885 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbZLZJaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 04:30:08 -0500
Received: from localhost.localdomain ([127.0.0.1]:36627 "EHLO h5.dl5rb.org.uk"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S1491000AbZLZJaH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Dec 2009 10:30:07 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cb81ca3..4725a54 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1445,7 +1445,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	if (!dev)
 		goto free_dst;
 
-	/* Copy neighbout for reachability confirmation */
+	/* Copy neighbour for reachability confirmation */
 	dst0->neighbour = neigh_clone(dst->neighbour);
 
 	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);

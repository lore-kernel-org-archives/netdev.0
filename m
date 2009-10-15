From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] iproute2: Support 20-byte link layer address in idxmap
Date: Thu, 15 Oct 2009 14:53:21 -0400
Message-ID: <1255632801-17802-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from LLMAIL1.LL.MIT.EDU ([129.55.12.41]:47276 "EHLO ll.mit.edu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751954AbZJOTIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 15:08:50 -0400
Received: (from smtp@localhost)
	by ll.mit.edu (8.12.10/8.8.8) id n9FJ8BuA024991
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 15:08:11 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the link-layer address field from 8 to 20 bytes to support InfiniBand.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 lib/ll_map.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/ll_map.c b/lib/ll_map.c
index 7c0bea2..5addf4a 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -31,7 +31,7 @@ struct idxmap
 	int		type;
 	int		alen;
 	unsigned	flags;
-	unsigned char	addr[8];
+	unsigned char	addr[20];
 	char		name[16];
 };
 
-- 
1.5.5.6


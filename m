From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/16] tipc: Rename "multicast-link" to "broadcast-link"
Date: Tue, 11 May 2010 20:30:07 -0400
Message-ID: <49f3ecdfa0f745a42bbdfda33f6a8feecad5bc45.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35228 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947Ab0ELAa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:27 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UR83000101
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:27 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Make a cosmetic change to the name displayed for the broadcast link,
to better reflect its true nature. Since TIPC utilizes this link to
distribute name table information, in addition to multicast messages
sent by user applications, the prior name "multicast-link" is
no longer appropriate.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 90a0519..a18f26d 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -119,7 +119,7 @@ static struct bclink *bclink = NULL;
 static struct link *bcl = NULL;
 static DEFINE_SPINLOCK(bc_lock);
 
-const char tipc_bclink_name[] = "multicast-link";
+const char tipc_bclink_name[] = "broadcast-link";
 
 
 static u32 buf_seqno(struct sk_buff *buf)
-- 
1.7.1.rc2


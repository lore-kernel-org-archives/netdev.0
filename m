From: Jim Cromie <jim.cromie@gmail.com>
Subject: [PATCH 06/11] enic: replace open-coded ARRAY_SIZE with macro
Date: Tue, 10 Apr 2012 18:56:09 -0600
Message-ID: <1334105769-9235-1-git-send-email-jim.cromie@gmail.com>
Cc: trivial@vger.kernel.org, Jim Cromie <jim.cromie@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52194 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759895Ab2DKA4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:56:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jim Cromie <jim.cromie@gmail.com>
---
 drivers/net/ethernet/cisco/enic/enic_pp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index dafea1e..43464f0 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -184,7 +184,7 @@ static int (*enic_pp_handlers[])(struct enic *enic, int vf,
 };
 
 static const int enic_pp_handlers_count =
-			sizeof(enic_pp_handlers)/sizeof(*enic_pp_handlers);
+			ARRAY_SIZE(enic_pp_handlers);
 
 static int enic_pp_preassociate(struct enic *enic, int vf,
 	struct enic_port_profile *prev_pp, int *restore_pp)
-- 
1.7.8.1

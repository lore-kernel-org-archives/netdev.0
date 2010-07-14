From: Chihau Chau <chihau@gmail.com>
Subject: [PATCH] Net: ethernet: pe2.c: fix EXPORT_SYMBOL macro code style issue
Date: Wed, 14 Jul 2010 16:24:34 -0400
Message-ID: <1279139074-13040-1-git-send-email-chihau@gmail.com>
Cc: tj@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Chihau Chau <chihau@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59401 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756791Ab0GNUYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:24:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chihau Chau <chihau@gmail.com>

This patch fix a code style issuei, if a function is exported, the
EXPORT_SYMBOL macro for it should follow immediately after the closing
function brace line.

Signed-off-by: Chihau Chau <chihau@gmail.com>
---
 net/ethernet/pe2.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ethernet/pe2.c b/net/ethernet/pe2.c
index eb00796..85d574a 100644
--- a/net/ethernet/pe2.c
+++ b/net/ethernet/pe2.c
@@ -28,11 +28,10 @@ struct datalink_proto *make_EII_client(void)
 
 	return proto;
 }
+EXPORT_SYMBOL(make_EII_client);
 
 void destroy_EII_client(struct datalink_proto *dl)
 {
 	kfree(dl);
 }
-
 EXPORT_SYMBOL(destroy_EII_client);
-EXPORT_SYMBOL(make_EII_client);
-- 
1.5.6.3


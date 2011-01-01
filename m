From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] net/Space: delete orphaned externs from deleted drivers
Date: Sat,  1 Jan 2011 18:15:01 -0500
Message-ID: <1293923701-14147-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56630 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab1AAXPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 18:15:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers associated with the prototypes in this commit have
been deleted some time ago, but the externs escaped detection.
Using a simple "git grep" shows that these references are
historical artefacts, only mentioned by the deleted lines.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 9bb405b..068c356 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -55,8 +55,6 @@ extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *el1_probe(int unit);
-extern struct net_device *wavelan_probe(int unit);
-extern struct net_device *arlan_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern struct net_device *elmc_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
@@ -68,7 +66,6 @@ extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern struct net_device *sonic_probe(int unit);
-extern struct net_device *SK_init(int unit);
 extern struct net_device *seeq8005_probe(int unit);
 extern struct net_device *smc_init(int unit);
 extern struct net_device *atarilance_probe(int unit);
@@ -76,8 +73,6 @@ extern struct net_device *sun3lance_probe(int unit);
 extern struct net_device *sun3_82586_probe(int unit);
 extern struct net_device *apne_probe(int unit);
 extern struct net_device *cs89x0_probe(int unit);
-extern struct net_device *hplance_probe(int unit);
-extern struct net_device *bagetlance_probe(int unit);
 extern struct net_device *mvme147lance_probe(int unit);
 extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
-- 
1.7.3.3


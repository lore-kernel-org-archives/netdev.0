From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/3] nfp: remove linux/version.h includes
Date: Wed,  7 Sep 2016 19:45:35 +0100
Message-ID: <1473273937-9230-2-git-send-email-jakub.kicinski@netronome.com>
References: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35569 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756224AbcIGSqU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 14:46:20 -0400
Received: by mail-wm0-f47.google.com with SMTP id i204so101040243wma.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 11:46:20 -0700 (PDT)
In-Reply-To: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary version.h includes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 1 -
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 1 -
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c  | 1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 88678c172b19..e4fe0f080f34 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -41,7 +41,6 @@
  *          Chris Telfer <chris.telfer@netronome.com>
  */
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 7d7933d00b8f..4c9897220969 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -40,7 +40,6 @@
  *          Brad Petrus <brad.petrus@netronome.com>
  */
 
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 37abef016a0a..6f22b0e12ac7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -38,7 +38,6 @@
  *         Rolf Neugebauer <rolf.neugebauer@netronome.com>
  */
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-- 
1.9.1

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ethtool: Use noinline_for_stack
Date: Mon, 08 Mar 2010 20:46:03 +0100
Message-ID: <1268077563.2819.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:58465 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623Ab0CHTqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 14:46:10 -0500
Received: by bwz1 with SMTP id 1so3169726bwz.21
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 11:46:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use self documenting noinline_for_stack instead of duplicated comments.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/ethtool.c |   40 ++++++++--------------------------------
 1 file changed, 8 insertions(+), 32 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 33d2ded..f4cb6b6 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -200,10 +200,7 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_settings(dev, &cmd);
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_drvinfo info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -242,10 +239,7 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
 	return 0;
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_get_sset_info(struct net_device *dev,
+static noinline_for_stack int ethtool_get_sset_info(struct net_device *dev,
                                           void __user *useraddr)
 {
 	struct ethtool_sset_info info;
@@ -305,10 +299,7 @@ out:
 	return ret;
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc cmd;
 
@@ -321,10 +312,7 @@ static noinline int ethtool_set_rxnfc(struct net_device *dev, void __user *usera
 	return dev->ethtool_ops->set_rxnfc(dev, &cmd);
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -396,10 +384,7 @@ static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
 	list->count++;
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rx_ntuple cmd;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
@@ -867,10 +852,7 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
 
@@ -884,10 +866,7 @@ static noinline int ethtool_get_coalesce(struct net_device *dev, void __user *us
 	return 0;
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_set_coalesce(struct net_device *dev, void __user *useraddr)
+static noinline_for_stack int ethtool_set_coalesce(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce;
 
@@ -1297,10 +1276,7 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	return actor(dev, edata.data);
 }
 
-/*
- * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
- */
-static noinline int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
+static noinline_for_stack int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_flash efl;
 



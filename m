From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] sk98lin: ethtool perm_addr build fix
Date: Wed, 12 Sep 2007 13:30:01 +0200
Message-ID: <20070912133001.0896f0e7@oldman>
References: <6278d2220707271227g51cb147ch2f6dbc05c73f618d@mail.gmail.com>
	<20070911132423.62347d5c@oldman>
	<20070911132819.2cc5bbf4@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58211 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764797AbXILLa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:30:56 -0400
In-Reply-To: <20070911132819.2cc5bbf4@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Deal with API changes while sk98lin was removed.
ethtool_ops no longer has a perm_addr hook.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sk98lin/skethtool.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
index 3646069..5a6da89 100644
--- a/drivers/net/sk98lin/skethtool.c
+++ b/drivers/net/sk98lin/skethtool.c
@@ -616,7 +616,6 @@ const struct ethtool_ops SkGeEthtoolOps = {
 	.get_pauseparam		= getPauseParams,
 	.set_pauseparam		= setPauseParams,
 	.get_link		= ethtool_op_get_link,
-	.get_perm_addr		= ethtool_op_get_perm_addr,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= setScatterGather,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
-- 
1.5.2.5


From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 14/26] fs_enet: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:29 +0200
Message-ID: <26608b4505b43f3e43a4034f1ba131b681257bd9.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37938 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab2DDJA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:00:57 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj6so354813wib.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:00:56 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index e4e6cd2..2b7633f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -963,6 +963,7 @@ static const struct ethtool_ops fs_ethtool_ops = {
 	.get_msglevel = fs_get_msglevel,
 	.set_msglevel = fs_set_msglevel,
 	.get_regs = fs_get_regs,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.2.5

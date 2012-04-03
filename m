From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 10/28] davinci_emac: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:34 +0200
Message-ID: <bc98142efe31fd07b5a974c4bafdb200ceca79ab.1333474523.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60989 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026Ab2DCRsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:48:52 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3975805wgb.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:48:51 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 174a334..8aa3332 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -627,6 +627,7 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_coalesce = emac_get_coalesce,
 	.set_coalesce =  emac_set_coalesce,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 /**
-- 
1.7.2.5

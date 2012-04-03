From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 24/28] smsc9420: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:48 +0200
Message-ID: <34a6aae2dd814bd1f1cb54954a63f56625615305.1333474525.git.richardcochran@gmail.com>
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
Received: from mail-wg0-f42.google.com ([74.125.82.42]:52611 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab2DCRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:49:53 -0400
Received: by wgbds11 with SMTP id ds11so3550134wgb.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:49:52 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 3838647..f80ec68 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -469,6 +469,7 @@ static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.set_eeprom = smsc9420_ethtool_set_eeprom,
 	.get_regs_len = smsc9420_ethtool_getregslen,
 	.get_regs = smsc9420_ethtool_getregs,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 /* Sets the device MAC address to dev_addr */
-- 
1.7.2.5

From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 23/28] smsc911x: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:47 +0200
Message-ID: <b3d68f99b29859be1ea76d87716b843a6ac3f267.1333474524.git.richardcochran@gmail.com>
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
Received: from mail-we0-f174.google.com ([74.125.82.174]:60390 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab2DCRtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:49:49 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so2519946wej.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:49:49 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 4a69710..519ed8e 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2070,6 +2070,7 @@ static const struct ethtool_ops smsc911x_ethtool_ops = {
 	.get_eeprom_len = smsc911x_ethtool_get_eeprom_len,
 	.get_eeprom = smsc911x_ethtool_get_eeprom,
 	.set_eeprom = smsc911x_ethtool_set_eeprom,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops smsc911x_netdev_ops = {
-- 
1.7.2.5

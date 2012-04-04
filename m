From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 21/26] smsc911x: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:36 +0200
Message-ID: <7e458806319d66b2292ca41cbf6f53dc4a2a410e.1333529506.git.richardcochran@gmail.com>
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
	with ESMTP id S1755770Ab2DDJB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:01:29 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj6so354813wib.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:01:28 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
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

From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 0/2] Display classifier filters using ethtool
Date: Mon, 21 Jul 2014 17:22:16 +0530
Message-ID: <1405943538-3086-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:65055 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347AbaGULxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 07:53:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds ethtool support to show classifier filters added by driver.

v2:
The patch 1/2 removes the $ifdef's around the filter structure. Making it
available always. So that .get_rxnfc() can be implimented without any #ifdefs

Please apply this to net-next.

Govindarajulu Varadarajan (2):
  enic: remove #ifdef CONFIG_RFS_ACCEL around filter structures
  enic: Add ethtool support to show classifier filters added by the
    driver

 drivers/net/ethernet/cisco/enic/enic.h         |  5 --
 drivers/net/ethernet/cisco/enic/enic_clsf.c    | 87 +++++++++++++----------
 drivers/net/ethernet/cisco/enic/enic_clsf.h    | 23 ++++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 98 ++++++++++++++++++++++++++
 4 files changed, 168 insertions(+), 45 deletions(-)

-- 
2.0.2

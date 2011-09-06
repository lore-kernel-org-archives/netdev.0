From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 0/4] ethtool: Fixes for RX NFC API
Date: Wed, 07 Sep 2011 00:44:53 +0100
Message-ID: <1315352693.2788.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45134 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab1IFXo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:44:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes some minor flaws in the documentation and the API itself.

Ben.

Ben Hutchings (4):
  ethtool: Make struct ethtool_rxnfc kernel-doc more self-consistent
  ethtool: Explicitly state that RX NFC rule locations are priorities
  ethtool: Clean up definitions of rule location arrays in RX NFC
  ethtool: Update ethtool_rxnfc::rule_cnt on return from
    ETHTOOL_GRXCLSRLALL

 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |    5 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    7 ++--
 drivers/net/ethernet/sfc/ethtool.c                 |    2 +-
 drivers/net/ethernet/sun/niu.c                     |    6 ++-
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |    2 +-
 include/linux/ethtool.h                            |   33 +++++++++----------
 8 files changed, 31 insertions(+), 28 deletions(-)

-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

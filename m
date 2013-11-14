From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 0/6] net_tstamp: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 00:39:02 +0000
Message-ID: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53430 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3KNAjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 19:39:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes very similar bugs in 6 implementations of
SIOCSHWTSTAMP.

Ben.

Ben Hutchings (6):
  tg3: Validate hwtstamp_config completely before applying it
  e1000e: Validate hwtstamp_config completely before applying it
  pch_gbe: Validate hwtstamp_config completely before applying it
  stmmac: Validate hwtstamp_config completely before applying it
  ti_cpsw: Validate hwtstamp_config completely before applying it
  ixp4xx_eth: Validate hwtstamp_config completely before applying it

 drivers/net/ethernet/broadcom/tg3.c                  | 16 +++++++---------
 drivers/net/ethernet/intel/e1000e/netdev.c           | 14 ++++++--------
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 12 +++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    | 12 +++---------
 drivers/net/ethernet/ti/cpsw.c                       | 18 ++++++++----------
 drivers/net/ethernet/xscale/ixp4xx_eth.c             | 12 +++---------
 6 files changed, 30 insertions(+), 54 deletions(-)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

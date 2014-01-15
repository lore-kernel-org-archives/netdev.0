From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next 0/2] r6040: misc fixes
Date: Wed, 15 Jan 2014 13:04:24 -0800
Message-ID: <1389819866-32142-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:46329 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaAOVEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 16:04:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are two small fixes, patch 1 could potentially be backported to stable
trees since it affects MDIO operations.

Thanks!

Florian Fainelli (2):
  r6040: add delays in MDIO read/write polling loops
  r6040: use ETH_ZLEN instead of MISR for SKB length checking

 drivers/net/ethernet/rdc/r6040.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

-- 
1.8.3.2

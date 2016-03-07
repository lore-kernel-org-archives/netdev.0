From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH v2 net-next 0/8] bnxt_en: Updates for net-next.
Date: Mon,  7 Mar 2016 15:38:40 -0500
Message-ID: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:4365 "EHLO
	mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbcCGUit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updates to support autoneg for all supported speeds, add PF port statistics,
and Advanced Error Reporting.

v2: Fixed patch 3 to not use parentheses on function return.

Michael Chan (8):
  bnxt_en: Refactor bnxt_fw_to_ethtool_advertised_spds().
  bnxt_en: Add reporting of link partner advertisement.
  bnxt_en: Use common function to get ethtool supported flags.
  bnxt_en: Extend autoneg to all speeds.
  bnxt_en: Add port statistics support.
  bnxt_en: Include some hardware port statistics in ndo_get_stats64().
  bnxt_en: Include hardware port statistics in ethtool -S.
  bnxt_en: Enable AER support.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 178 +++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  17 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 201 +++++++++++++++++-----
 3 files changed, 344 insertions(+), 52 deletions(-)

-- 
1.8.3.1

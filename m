From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 0/5] bnxt_en: Bug fixes.
Date: Wed, 10 Feb 2016 17:33:45 -0500
Message-ID: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:29950
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865AbcBJWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed autoneg logic and some related cleanups, fixed tx push operation,
and reduced default ring sizes.

Michael Chan (5):
  bnxt_en: Fix ethtool autoneg logic.
  bnxt_en: Cleanup and Fix flow control setup logic
  bnxt_en: Remove 20G support and advertise only 40GbaseCR4.
  bnxt_en: Fix implementation of tx push operation.
  bnxt_en: Reduce default ring sizes.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 62 ++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 15 ++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 46 +++++------------
 3 files changed, 56 insertions(+), 67 deletions(-)

-- 
1.8.3.1

From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/11] bnxt_en: Updates for net-next.
Date: Mon, 13 Jun 2016 02:25:27 -0400
Message-ID: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33894 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964806AbcFMGZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id 62so42966516pfd.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-Add default VLAN support for VFs.
-Add NPAR (NIC partioning) support.
-Add support for new device 5731x and 5741x. GRO logic is different.
-Support new ETHTOOL_{G|S}LINKSETTINGS.

Please review.  Thanks.

Michael Chan (10):
  bnxt_en: Add function for VF driver to query default VLAN.
  bnxt_en: Add new function bnxt_reset().
  bnxt_en: Handle VF_CFG_CHANGE event from firmware.
  bnxt_en: Add PCI device ID for 57404 NPAR devices.
  bnxt_en: Define the supported chip numbers.
  bnxt_en: Refactor bnxt_gro_skb().
  bnxt_en: Add GRO logic for BCM5731X chips.
  bnxt_en: Add BCM5731X and BCM5741X device IDs.
  bnxt_en: Don't allow autoneg on cards that don't support it.
  bnxt_en: Support new ETHTOOL_{G|S}LINKSETTINGS API.

Satish Baddipadige (1):
  bnxt_en: Enable NPAR (NIC Partitioning) Support.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 283 +++++++++++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  62 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 199 +++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |   3 +
 4 files changed, 435 insertions(+), 112 deletions(-)

-- 
1.8.3.1

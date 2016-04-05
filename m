From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 0/9] bnxt_en: Updates for net-next.
Date: Tue,  5 Apr 2016 14:08:54 -0400
Message-ID: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:6049 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758844AbcDESJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 14:09:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update to latest firmware interface, add EEE feature, unsupported SFP+
module warning, and ethtool -s improvements.

v2: Removed the GEEPROM patch and added more comments to the get_eee patch.

Michael Chan (9):
  bnxt_en: Update to Firmware 1.2.2 spec.
  bnxt_en: Improve flow control autoneg with Firmware 1.2.1 interface.
  bnxt_en: Add basic EEE support.
  bnxt_en: Add EEE setup code.
  bnxt_en: Add get_eee() and set_eee() ethtool support.
  bnxt_en: Set async event bits when registering with the firmware.
  bnxt_en: Add unsupported SFP+ module warnings.
  bnxt_en: Check for valid forced speed during ethtool -s.
  bnxt_en: Improve ethtool .get_settings().

 drivers/net/ethernet/broadcom/bnxt/bnxt.c          | 259 ++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          |  17 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  | 165 ++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h  |   4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h   |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h      | 433 +++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |  14 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |   2 +-
 9 files changed, 803 insertions(+), 95 deletions(-)

-- 
1.8.3.1

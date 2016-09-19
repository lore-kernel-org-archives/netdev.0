From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/10] bnxt: update for net-next.
Date: Mon, 19 Sep 2016 03:57:59 -0400
Message-ID: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33315 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754116AbcISH6Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:24 -0400
Received: by mail-pf0-f182.google.com with SMTP id 21so37609509pfy.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Misc. changes and minor bug fixes for net-next.  Please review.

Deepak Khungar (1):
  bnxt_en: Support for "ethtool -r" command

Eddie Wai (1):
  bnxt_en: Fixed the VF link status after a link state change

Michael Chan (7):
  bnxt_en: Use RSS flags defined in the bnxt_hsi.h file.
  bnxt_en: Simplify PCI device names and add additinal PCI IDs.
  bnxt_en: Update to firmware interface spec 1.5.1.
  bnxt_en: Fix ethtool -l|-L inconsistent channel counts.
  bnxt_en: Re-arrange bnxt_hwrm_func_qcaps().
  bnxt_en: Call firmware to approve the random VF MAC address.
  bnxt_en: Pad TX packets below 52 bytes.

Rob Swindell (1):
  bnxt_en: Added support for Secure Firmware Update

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  131 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   22 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  187 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h  |   16 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 1251 ++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |   84 +-
 6 files changed, 1069 insertions(+), 622 deletions(-)

-- 
1.8.3.1

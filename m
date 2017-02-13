From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/9] bnxt_en: Misc updates.
Date: Sun, 12 Feb 2017 19:18:09 -0500
Message-ID: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:35441 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdBMASt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:18:49 -0500
Received: by mail-it0-f43.google.com with SMTP id 203so170031214ith.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous updates include update of the firmware spec, ethtool flash
enhancement, ethtool -l minor fix, NTUPLE support enhancements, FEC
link settings message during link up, and new PCI IDs.  Please review.
Thanks.

Deepak Khungar (1):
  bnxt_en: Added PCI IDs for BCM57452 and BCM57454 ASICs

Kshitij Soni (1):
  bnxt_en: Retry failed NVM_INSTALL_UPDATE with defragmentation flag.

Michael Chan (7):
  bnxt_en: Update to firmware interface spec 1.7.0.
  bnxt_en: Fix ethtool -l pre-set max combined channel.
  bnxt_en: Allow NETIF_F_NTUPLE to be enabled on VFs.
  bnxt_en: Add hardware NTUPLE filter for encapsulated packets.
  bnxt_en: Do not setup PHY unless driving a single PF.
  bnxt_en: Print FEC settings as part of the linkup dmesg.
  bnxt_en: Fix bnxt_setup_tc() error message.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  52 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   9 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  34 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 437 ++++++++++++++++++----
 4 files changed, 431 insertions(+), 101 deletions(-)

-- 
1.8.3.1

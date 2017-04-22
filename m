From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/5] bnxt_en: Updates for net-next.
Date: Fri, 21 Apr 2017 20:11:21 -0400
Message-ID: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:35728 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162642AbdDVALg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:11:36 -0400
Received: by mail-wr0-f175.google.com with SMTP id z52so21364959wrc.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:11:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous updates include passing DCBX RoCE VLAN priority to firmware,
checking one more new firmware flag before allowing DCBX to run on the host,
adding 100Gbps speed support, adding check to disallow speed settings on
Multi-host NICs, and a minor fix for reporting VF attributes.

Deepak Khungar (2):
  bnxt_en: Add 100G link speed reporting for BCM57454 ASIC in ethtool
  bnxt_en: Restrict a PF in Multi-Host mode from changing port PHY
    configuration

Michael Chan (3):
  bnxt_en: Pass DCB RoCE app priority to firmware.
  bnxt_en: Fix VF attributes reporting.
  bnxt_en: Check the FW_LLDP_AGENT flag before allowing DCBX host agent.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  17 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     | 108 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h     |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  14 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |   8 +-
 6 files changed, 140 insertions(+), 10 deletions(-)

-- 
1.8.3.1

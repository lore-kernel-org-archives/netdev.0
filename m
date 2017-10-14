From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/6] bnxt_en: bug fixes.
Date: Fri, 13 Oct 2017 21:09:28 -0400
Message-ID: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:46436 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdJNBJq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 21:09:46 -0400
Received: by mail-qt0-f172.google.com with SMTP id 1so22690959qtn.3
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 18:09:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various bug fixes for the VF/PF link change logic, VF resource checking,
potential firmware response corruption on NVRAM and DCB parameters,
and reading the wrong register for PCIe link speed on the VF.

Michael Chan (4):
  bnxt_en: Improve VF/PF link change logic.
  bnxt_en: Don't use rtnl lock to protect link change logic in
    workqueue.
  bnxt_en: Fix VF resource checking.
  bnxt_en: Fix possible corrupted NVRAM parameters from firmware
    response.

Sankar Patchineelam (1):
  bnxt_en: Fix possible corruption in DCB parameters from firmware.

Vasundhara Volam (1):
  bnxt_en: Fix VF PCIe link speed and width logic.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 99 +++++++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  5 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     | 23 ++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   | 11 ++-
 5 files changed, 112 insertions(+), 34 deletions(-)

-- 
1.8.3.1

From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: bug fixes.
Date: Wed, 23 Aug 2017 19:34:02 -0400
Message-ID: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33359 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdHWXeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 19:34:19 -0400
Received: by mail-qk0-f169.google.com with SMTP id a77so8888494qkb.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 16:34:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3 bug fixes related to XDP ring accounting in bnxt_setup_tc(), freeing
MSIX vectors when bnxt_re unregisters, and preserving the user-administered
PF MAC address when disabling SRIOV.

Michael Chan (3):
  bnxt_en: Fix .ndo_setup_tc() to include XDP rings.
  bnxt_en: Free MSIX vectors when unregistering the device from bnxt_re.
  bnxt_en: Do not setup MAC address in bnxt_hwrm_func_qcaps().

 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 41 +++++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c |  2 ++
 2 files changed, 31 insertions(+), 12 deletions(-)

-- 
1.8.3.1

From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/2] bnxt_en: DCBX fixes.
Date: Tue, 16 May 2017 16:39:42 -0400
Message-ID: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34868 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEPUkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:40:19 -0400
Received: by mail-pg0-f41.google.com with SMTP id q125so62400088pgq.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:40:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2 bug fixes for the case where the NIC's firmware DCBX agent is enabled.
With these fixes, we will return the proper information to lldpad.

Michael Chan (2):
  bnxt_en: Call bnxt_dcb_init() after getting firmware DCBX
    configuration.
  bnxt_en: Check status of firmware DCBX agent before setting
    DCB_CAP_DCBX_HOST.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 3 +--
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 6 ++++--
 2 files changed, 5 insertions(+), 4 deletions(-)

-- 
1.8.3.1

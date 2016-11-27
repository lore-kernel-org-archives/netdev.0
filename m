From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/4] bnxt_en: Add DCBNL support.
Date: Sat, 26 Nov 2016 19:38:31 -0500
Message-ID: <1480207115-21294-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34797 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbcK0Ais (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 19:38:48 -0500
Received: by mail-pf0-f171.google.com with SMTP id c4so19067377pfb.1
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 16:38:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds DCBNL operations to support host-based IEEE DCBX.

Michael Chan (4):
  bnxt_en: Re-factor bnxt_setup_tc().
  bnxt_en: Update firmware header file to include DCB command structs.
  bnxt_en: Implement DCBNL to support host-based DCBX.
  bnxt_en: Add PFC statistics.

 drivers/net/ethernet/broadcom/Kconfig             |  10 +
 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  30 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  18 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     | 502 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h     |  59 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  23 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 326 ++++++++++++++
 8 files changed, 952 insertions(+), 18 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h

-- 
1.8.3.1

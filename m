From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 0/4] bnxt_en: Add DCBNL support.
Date: Fri,  2 Dec 2016 21:17:14 -0500
Message-ID: <1480731438-22671-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33683 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752614AbcLCCRa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 21:17:30 -0500
Received: by mail-pf0-f173.google.com with SMTP id d2so55456997pfd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 18:17:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds DCBNL operations to support host-based IEEE DCBX.

v2: Updated to the latest firmware interface spec.

David, please consider this series for net-next.

Michael Chan (4):
  bnxt_en: Re-factor bnxt_setup_tc().
  bnxt_en: Update firmware header file to latest 1.6.0.
  bnxt_en: Implement DCBNL to support host-based DCBX.
  bnxt_en: Add PFC statistics.

 drivers/net/ethernet/broadcom/Kconfig             |   10 +
 drivers/net/ethernet/broadcom/bnxt/Makefile       |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   54 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   22 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     |  502 ++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h     |   41 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |   23 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 1725 +++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |    8 +-
 9 files changed, 1672 insertions(+), 715 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h

-- 
1.8.3.1

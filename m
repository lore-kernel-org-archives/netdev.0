From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/10] bnxt_en: Updates for net-next.
Date: Mon, 24 Jul 2017 12:34:19 -0400
Message-ID: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:33219 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752492AbdGXQeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:44 -0400
Received: by mail-qt0-f169.google.com with SMTP id n42so73450059qtn.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series includes updating the firmware interface, adding
methods to get and set VEPA/VEB bridge modes, some minor DCBX and ETS
refinements, and 3 patches from Sathya Perla to implement initial
VF representors for SRIOV switching.

Michael Chan (7):
  bnxt_en: Update firmware interface spec to 1.8.0.
  bnxt_en: Retrieve the hardware bridge mode from the firmware.
  bnxt_en: Implement ndo_bridge_{get|set}link methods.
  bnxt_en: Add bnxt_get_num_stats() to centrally get the number of
    ethtool stats.
  bnxt_en: Allow the user to set ethtool stats-block-usecs to 0.
  bnxt_en: Report firmware DCBX agent.
  bnxt_en: Set ETS min_bw parameter for older firmware.

Sathya Perla (3):
  bnxt_en: add support to enable VF-representors
  bnxt_en: add vf-rep RX/TX and netdev implementation
  bnxt_en: add support for port_attr_get and and get_phys_port_name

 drivers/net/ethernet/broadcom/Kconfig             |   1 +
 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 237 +++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  54 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     |  17 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h     |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  33 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 322 ++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |  15 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     | 489 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h     |  42 ++
 11 files changed, 1134 insertions(+), 79 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h

-- 
1.8.3.1

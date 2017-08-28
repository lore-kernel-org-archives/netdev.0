From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/11] bnxt_en: Updates.
Date: Mon, 28 Aug 2017 13:40:24 -0400
Message-ID: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:36235 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdH1Rkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:49 -0400
Received: by mail-qt0-f179.google.com with SMTP id v29so5264424qtv.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various changes including updated firmware interface, improved TX ring
allocation scheme, improved out-of-memory logic in NAPI loop, reduced
default rings on multi-port devices, new PCI IDs. Of particular note,

CPU affinity hints from Vasundhara Volam.

TC Flower eswitch support from Sathya Perla.

Michael Chan (4):
  bnxt_en: Update firmware interface spec. to 1.8.1.4.
  bnxt_en: Improve tx ring reservation logic.
  bnxt_en: Improve -ENOMEM logic in NAPI poll loop.
  bnxt_en: Reduce default rings on multi-port cards.

Ray Jui (1):
  bnxt: Add PCIe device IDs for bcm58802/bcm58808

Sathya Perla (4):
  bnxt_en: fix clearing devlink ptr from bnxt struct
  bnxt_en: bnxt: add TC flower filter offload support
  bnxt_en: add TC flower offload flow_alloc/free FW cmds
  bnxt_en: add code to query TC flower offload stats

Scott Branden (1):
  bnxt: initialize board_info values with proper enums

Vasundhara Volam (1):
  bnxt_en: assign CPU affinity hints to bnxt_en IRQs

 drivers/net/ethernet/broadcom/Kconfig             |   9 +
 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 198 +++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  41 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |   3 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 186 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c      | 834 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h      | 158 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     |  22 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h     |  22 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |   4 +-
 11 files changed, 1407 insertions(+), 72 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h

-- 
1.8.3.1

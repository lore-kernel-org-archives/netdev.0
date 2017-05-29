From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/7] bnxt_en: Misc. updates for net-next.
Date: Mon, 29 May 2017 19:06:03 -0400
Message-ID: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:32792 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdE2XGh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:37 -0400
Received: by mail-qt0-f169.google.com with SMTP id t26so58590613qtg.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 1st 2 patches add short firmware message support for new VF devices.
The 3rd patch adds a pci shutdown callback for the RDMA driver for proper
shutdown.  The next 3 patches improve the doorbell operations by
elimiating the double doorbell workaround on newer chips, and by adding
xmit_more support.  The last patch adds a parameter to bnxt_set_dflt_rings().

Deepak Khungar (2):
  bnxt_en: Support for Short Firmware Message
  bnxt_en: Add PCI IDs for BCM57454 VF devices.

Michael Chan (5):
  bnxt_en: Add a callback to inform RDMA driver during PCI shutdown.
  bnxt_en: Add additional chip ID definitions.
  bnxt_en: Optimize doorbell write operations for newer chips.
  bnxt_en: Implement xmit_more.
  bnxt_en: Pass in sh parameter to bnxt_set_dflt_rings().

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 114 +++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  42 +++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |   3 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c     |  19 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.h     |   2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |   2 +-
 6 files changed, 149 insertions(+), 33 deletions(-)

-- 
1.8.3.1

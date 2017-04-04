From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/12] bnxt_en: Updates for net-next.
Date: Tue,  4 Apr 2017 18:14:05 -0400
Message-ID: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38887 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754859AbdDDWOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:35 -0400
Received: by mail-wm0-f43.google.com with SMTP id t189so39779680wmt.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main changes are to add WoL and selftest features, optimize XDP_TX by
using short BDs, and to cap the usage of MSIX.

Michael Chan (12):
  bnxt_en: Update firmware interface spec to 1.7.6.2.
  bnxt_en: Add basic WoL infrastructure.
  bnxt_en: Add pci shutdown method.
  bnxt_en: Add ethtool get_wol method.
  bnxt_en: Add ethtool set_wol method.
  bnxt_en: Add suspend/resume callbacks.
  bnxt_en: Add basic ethtool -t selftest support.
  bnxt_en: Add ethtool mac loopback self test.
  bnxt_en: Add PHY loopback to ethtool self-test.
  bnxt_en: Add interrupt test to ethtool -t selftest.
  bnxt_en: Use short TX BDs for the XDP TX ring.
  bnxt_en: Cap the msix vector with the max completion rings.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 207 ++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  21 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 413 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |   3 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 325 +++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |   8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h   |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |  20 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h     |   2 +
 9 files changed, 942 insertions(+), 58 deletions(-)

-- 
1.8.3.1

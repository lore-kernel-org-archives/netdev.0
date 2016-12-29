From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/14] bnxt_en: updates for net-next.
Date: Thu, 29 Dec 2016 12:13:30 -0500
Message-ID: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33882 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcL2ROA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:00 -0500
Received: by mail-pf0-f173.google.com with SMTP id c4so63186171pfb.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:13:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series for net-next contains cleanups, new features and minor
fixes.  The driver specific busy polling code is removed to use busy
polling support in core networking.  Hardware RFS support is enhanced with
added ipv6 flows support and VF support.  A new scheme to allocate TX
rings from the firmware is implemented for newer chips and firmware.  Plus
some misc. cleanups, minor fixes, and to add the maintainer entry.  Please
review.

Michael Chan (14):
  bnxt_en: Remove busy poll logic in the driver.
  bnxt_en: Use napi_complete_done()
  bnxt_en: Improve the IRQ disable sequence during shutdown.
  bnxt_en: Fix and clarify link_info->advertising.
  bnxt_en: Refactor TPA code path.
  bnxt_en: Add function to get vnic capability.
  bnxt_en: Refactor code that determines RFS capability.
  bnxt_en: Add new hardware RFS mode.
  bnxt_en: Assign additional vnics to VFs.
  bnxt_en: Add IPV6 hardware RFS support.
  bnxt_en: Implement new scheme to reserve tx rings.
  bnxt_en: Set default completion ring for async events.
  bnxt_en: Handle no aggregation ring gracefully.
  MAINTAINERS: Add bnxt_en maintainer info.

 MAINTAINERS                                       |   6 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 385 +++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 108 +-----
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  73 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     |  34 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |  15 +-
 6 files changed, 388 insertions(+), 233 deletions(-)

-- 
1.8.3.1

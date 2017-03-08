From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/4] bnxt_en: Misc. small fixes.
Date: Wed,  8 Mar 2017 18:44:31 -0500
Message-ID: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35942 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752052AbdCHXqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 18:46:03 -0500
Received: by mail-wm0-f48.google.com with SMTP id n11so127218305wma.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 15:44:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes include moving the initial function reset, notifying the RDMA driver
during tx timeout, setting dcbx_cap properly depending on whether the
firmware agent is running or not, and an autoneg related improvement. 

Michael Chan (4):
  bnxt_en: Perform function reset earlier during probe.
  bnxt_en: Call bnxt_ulp_stop() during tx timeout.
  bnxt_en: Check if firmware LLDP agent is running.
  bnxt_en: Ignore 0 value in autoneg supported speed from firmware.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 25 ++++++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c |  2 +-
 3 files changed, 20 insertions(+), 8 deletions(-)

-- 
1.8.3.1

From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/4] bnxt_en: Updates.
Date: Wed, 16 Nov 2016 21:13:06 -0500
Message-ID: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36440 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcKQCUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 21:20:52 -0500
Received: by mail-pf0-f182.google.com with SMTP id 189so46121052pfz.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 18:20:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New firmware spec. update, autoneg update, and UDP RSS support.

Michael Chan (4):
  bnxt_en: Update firmware interface spec to 1.5.4.
  bnxt_en: Enhance autoneg support.
  bnxt_en: Add UDP RSS support for 57X1X chips.
  bnxt_en: Add ethtool -n|-N rx-flow-hash support.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  52 +++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |   4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 167 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     |  91 +++++++++++-
 4 files changed, 298 insertions(+), 16 deletions(-)

-- 
1.8.3.1

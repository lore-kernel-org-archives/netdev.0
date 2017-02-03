From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v2 0/2] net: ethernet: bgmac: bug fixes
Date: Fri,  3 Feb 2017 16:08:51 -0500
Message-ID: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33605 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVJC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:09:02 -0500
Received: by mail-qt0-f178.google.com with SMTP id v23so54601182qtb.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:09:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in v2:
* Reworked the first match to make it more obvious what portions of the
  register were being preserved (Per Rafal Mileki) 
* Style change to reorder the function variables in patch 2 (per Sergei
  Shtylyov)


Bug fixes for bgmac driver

Hari Vyas (1):
  net: ethernet: bgmac: mac address change bug

Zac Schroff (1):
  net: ethernet: bgmac: init sequence bug

 drivers/net/ethernet/broadcom/bgmac-platform.c | 14 +++++++++-----
 drivers/net/ethernet/broadcom/bgmac.c          |  6 +++++-
 drivers/net/ethernet/broadcom/bgmac.h          | 16 ++++++++++++++++
 3 files changed, 30 insertions(+), 6 deletions(-)

-- 
2.7.4

From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net v3 0/2] net: ethernet: bgmac: bug fixes
Date: Wed,  8 Feb 2017 16:12:55 -0500
Message-ID: <1486588377-7681-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:33793 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdBHVho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 16:37:44 -0500
Received: by mail-qt0-f180.google.com with SMTP id w20so173674938qtb.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 13:37:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in v3:
* Reworked the init sequence patch to only remove the device reset if
  the device is actually in reset.  Given that this code doesn't bear
  much resemblance to the original code, I'm changing the author of the
  patch.  This was tested on NS2 SVK.

Changes in v2:
* Reworked the first match to make it more obvious what portions of the
  register were being preserved (Per Rafal Mileki)
* Style change to reorder the function variables in patch 2 (per Sergei
  Shtylyov)


Bug fixes for bgmac driver


Hari Vyas (1):
  net: ethernet: bgmac: mac address change bug

Jon Mason (1):
  net: ethernet: bgmac: init sequence bug

 drivers/net/ethernet/broadcom/bgmac-platform.c | 27 ++++++++++++++++----------
 drivers/net/ethernet/broadcom/bgmac.c          |  6 +++++-
 drivers/net/ethernet/broadcom/bgmac.h          | 16 +++++++++++++++
 3 files changed, 38 insertions(+), 11 deletions(-)

-- 
2.7.4

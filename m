From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net v5 0/2] net: ethernet: bgmac: bug fixes
Date: Thu,  2 Mar 2017 17:59:55 -0500
Message-ID: <1488495597-5835-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35247 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdCBXBl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 18:01:41 -0500
Received: by mail-qk0-f181.google.com with SMTP id m67so34485936qkf.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 15:00:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in v5:
* Rebased to the latest code and fixed up a compile error due to the
  mac_addr struct going away (found by David Miller)

Changes in v4:
* Added the udelays from the previous code (per David Miller)

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

 drivers/net/ethernet/broadcom/bgmac-platform.c | 27 +++++++++++++++++---------
 drivers/net/ethernet/broadcom/bgmac.c          |  6 +++++-
 drivers/net/ethernet/broadcom/bgmac.h          | 16 +++++++++++++++
 3 files changed, 39 insertions(+), 10 deletions(-)

-- 
2.7.4

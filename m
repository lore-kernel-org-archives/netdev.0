From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: [net 0/3] gianfar: Tx flow control fix (adjust_link)
Date: Fri, 1 Sep 2017 12:41:00 +0300
Message-ID: <1504258863-2058-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0074.outbound.protection.outlook.com ([104.47.37.74]:39800
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751705AbdIAJlI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 05:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a small blunder in the Tx pause frame settings, that
went unnoticed in the tangled code of adjust_link().
I followed up with a couple of simple refactoring patches,
aiming to make adjust_link() more manageable.

(The last 2 patches may be postponed if they are too much
for the current stage of net.)

Claudiu Manoil (3):
  gianfar: Fix Tx flow control deactivation
  gianfar: Refactor link speed update (adjust_link)
  gianfar: Refactor link flow control update (adjust_link)

 drivers/net/ethernet/freescale/gianfar.c | 134 ++++++++++++++++---------------
 1 file changed, 70 insertions(+), 64 deletions(-)

-- 
2.7.4

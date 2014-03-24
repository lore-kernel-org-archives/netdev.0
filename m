From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/3] net: phy: bcm7xxx: workaround updates
Date: Mon, 24 Mar 2014 16:36:46 -0700
Message-ID: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60866 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbaCXXhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:37:03 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so6137980pab.38
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 16:37:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch updates the BCM7xxx internal PHY workaround, this time with
defines for the registers we are touching.

Thanks!

Florian Fainelli (3):
  net: phy: bcm7xxx: define constants for our registers
  net: phy: bcm7xxx: fix spurious MDIO failures during workaround
  net: phy: bcm7xxx: properly clear AFE_RX_LP_COUNTER

 drivers/net/phy/bcm7xxx.c | 58 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 37 insertions(+), 21 deletions(-)

-- 
1.8.3.2

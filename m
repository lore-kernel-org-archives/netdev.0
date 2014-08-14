From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: phy: bcm7xxx internal PHY fixes
Date: Thu, 14 Aug 2014 16:52:50 -0700
Message-ID: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:42277 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaHNXxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:53:15 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so2423812pde.10
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:53:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are 3 small fixes for the Broadcom BCM7xxx internal PHY targeting
suspend/resume issues.

Thanks!

Florian Fainelli (3):
  net: phy: bcm7xxx: remove 28nm wildcard entry
  net: phy: bcm7xxx: re-advertise all supported modes out of suspend
  net: phy: bcm7xxx: remove suspend callback for 28nm PHYs

 drivers/net/phy/bcm7xxx.c | 42 +++++++++++++++++++++---------------------
 include/linux/brcmphy.h   |  1 -
 2 files changed, 21 insertions(+), 22 deletions(-)

-- 
1.9.1

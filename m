From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: phy: bcm7xxx: workaround updates
Date: Tue, 11 Nov 2014 14:55:09 -0800
Message-ID: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:51676 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbaKKWzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:55:20 -0500
Received: by mail-pd0-f181.google.com with SMTP id y10so10969999pdj.12
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:55:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains some updates to the Broadcom BCM7xxx internal
PHY driver, including:

- removing an annonying print that would appear during interface up/down and
  suspend/resume cycles
- drop a workaround sequence for a non-production PHY revision
- add new workarounds for the latest and greatest PHY devices found out ther

Thanks!

Florian Fainelli (5):
  net: phy: bcm7xxx: only show PHY revision once
  net: phy: bcm7xxx: drop A0 revision workaround and fix B0 workaround
  net: phy: bcm7xxx: introduce r_rc_cal_reset helper
  net: phy: bcm7xxx: add PHY revision D0 workaround sequence
  net: phy: bcm7xxx: add workaround for PHY revision E0 and F0

 drivers/net/phy/bcm7xxx.c | 134 +++++++++++++++++++++++++++++++---------------
 1 file changed, 90 insertions(+), 44 deletions(-)

-- 
1.9.1

From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: broadcom: fix FIXED_PHY dependencies
Date: Mon, 15 Dec 2014 09:57:12 -0800
Message-ID: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:51365 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaLOR5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:57:37 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so12270053pad.15
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 09:57:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series removes the bogus "select FIXED_PHY if FOO=y" that I have
been using in GENET, SYSTEMPORT and the SF2 DSA switch driver.

Thanks!

Florian Fainelli (3):
  net: bcmgenet: always select FIXED_PHY
  net: systemport: always select FIXED_PHY
  net: dsa: bcm_sf2: always select FIXED_PHY

 drivers/net/dsa/Kconfig               | 2 +-
 drivers/net/ethernet/broadcom/Kconfig | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

-- 
2.1.0

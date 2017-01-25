From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 0/3] net-next: Broadcom PHY driver cleanup
Date: Wed, 25 Jan 2017 21:00:24 +0100
Message-ID: <20170125200027.14387-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34878 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdAYUAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:00:47 -0500
Received: by mail-lf0-f67.google.com with SMTP id v186so22088152lfa.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 12:00:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

I will probably need to use broadcom.ko for PHY connected to interface
of bgmac supported device so I started looking at it willing to
understand it better.

I found AUXCTL part of the driver / lib a bit confusing and hard to read
so I'm trying to clean it up a bit. I hope this patchset makes following
AUXCTL operations much easier making it clear which defines are for
registers and which for values.

There is no functional change in this pachset.

Rafał Miłecki (3):
  net: phy: broadcom: use auxctl reading helper in BCM54612E code
  net: phy: broadcom: drop duplicated define for RGMII SKEW delay
  net: phy: bcm-phy-lib: clean up remaining AUXCTL register defines

 drivers/net/phy/broadcom.c |  8 +++-----
 include/linux/brcmphy.h    | 16 +++++++---------
 2 files changed, 10 insertions(+), 14 deletions(-)

-- 
2.11.0

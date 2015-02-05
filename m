From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: dsa: bcm_sf2: GPHY power down
Date: Thu,  5 Feb 2015 11:40:40 -0800
Message-ID: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49441 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbbBETky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:40:54 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so12044804pad.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:40:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series implement GPHY power up and down in the SF2 switch
driver in order to conserve power whenever possible (e.g: port is brought
down or unused during Wake-on-LAN).

Florian Fainelli (2):
  net: dsa: bcm_sf2: move GPHY enabling to its own function
  net: dsa: bcm_sf2: implement GPHY power down

 drivers/net/dsa/bcm_sf2.c      | 64 ++++++++++++++++++++++++++++++++++--------
 drivers/net/dsa/bcm_sf2_regs.h |  4 +++
 2 files changed, 56 insertions(+), 12 deletions(-)

-- 
2.1.0

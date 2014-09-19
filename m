From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] dsa: Broadcom SF2 suspend/resume and WoL
Date: Thu, 18 Sep 2014 17:31:21 -0700
Message-ID: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:47693 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbaISAbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:31:46 -0400
Received: by mail-pa0-f41.google.com with SMTP id et14so2637116pad.28
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:31:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch add supports for suspend/resume and configuring Wake-on-LAN
for Broadcom Starfighter 2 switches.

Thank you!

Florian Fainelli (4):
  net: dsa: allow switch drivers to implement suspend/resume hooks
  net: dsa: bcm_sf2: add suspend/resume callbacks
  net: dsa: add {get,set}_wol callbacks to slave devices
  net: dsa: bcm_sf2: add support for Wake-on-LAN

 drivers/net/dsa/bcm_sf2.c | 143 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h |   3 +
 include/net/dsa.h         |  14 +++++
 net/dsa/dsa.c             |  80 ++++++++++++++++++++++++++
 net/dsa/dsa_priv.h        |   2 +
 net/dsa/slave.c           |  54 +++++++++++++++++
 6 files changed, 296 insertions(+)

-- 
1.9.1

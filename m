From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/6] net: dsa: EEE and other PM features
Date: Wed, 24 Sep 2014 17:05:16 -0700
Message-ID: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45293 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIYAF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:05:59 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so9722718pad.12
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:05:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This patch set allows DSA switch drivers to enable/disable/query EEE on a
per-port level, as well as control precisely which switch ports are
enable/disabled.

I might already be too late for net-next, if that's the case, I will repost
when the tree re-opens.

Thanks!

Florian Fainelli (6):
  net: dsa: start and stop the PHY state machine
  net: dsa: allow enabling and disable switch ports
  net: dsa: bcm_sf2: disable RGMII interface(s) when link is down
  net: dsa: bcm_sf2: add port_enable/disable callbacks
  net: dsa: allow switches driver to implement get/set EEE
  net: dsa: bcm_sf2: add support for controlling EEE

 drivers/net/dsa/bcm_sf2.c      | 138 +++++++++++++++++++++++++++++++++++------
 drivers/net/dsa/bcm_sf2.h      |   3 +
 drivers/net/dsa/bcm_sf2_regs.h |   3 +
 include/net/dsa.h              |  17 +++++
 net/dsa/slave.c                |  60 ++++++++++++++++++
 5 files changed, 203 insertions(+), 18 deletions(-)

-- 
1.9.1

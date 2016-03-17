From: Vishal Thanki <vishalthanki@gmail.com>
Subject: [PATCH] Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 14:59:06 +0100
Message-ID: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
Cc: Vishal Thanki <vishalthanki@gmail.com>
To: ujhelyi.m@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35467 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbcCQN7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 09:59:15 -0400
Received: by mail-wm0-f41.google.com with SMTP id l68so227413521wml.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 06:59:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We had a requirement to disable the PHY link LEDs during system
standby mode without turning off the ethernet module. To achieve that,
I have prepared the sysfs interface turn on/off the PHY link LEDs.

Please suggest if there is any better way to achieve this.

Thanks,
Vishal

Vishal Thanki (1):
  net: phy: at803x: Add support to control PHY LEDs

 drivers/net/phy/Kconfig  |  7 +++++
 drivers/net/phy/at803x.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+)

-- 
2.4.3

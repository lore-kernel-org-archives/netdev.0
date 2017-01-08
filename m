From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: dsa: Make dsa_switch_ops const
Date: Sun,  8 Jan 2017 14:52:04 -0800
Message-ID: <20170108225208.15431-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33863 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933172AbdAHW7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:59:45 -0500
Received: by mail-pg0-f67.google.com with SMTP id b1so49807337pgc.1
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 14:59:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series allows us to annotate dsa_switch_ops with a const
qualifier.

Florian Fainelli (4):
  net: dsa: b53: Export most operations to other drivers
  net: dsa: bcm_sf2: Declare our own dsa_switch_ops
  net: dsa: Encapsulate legacy switch drivers into dsa_switch_driver
  net: dsa: Make dsa_switch_ops const

 drivers/net/dsa/b53/b53_common.c | 81 +++++++++++++++++++++++-----------------
 drivers/net/dsa/b53/b53_priv.h   | 33 ++++++++++++++++
 drivers/net/dsa/bcm_sf2.c        | 53 ++++++++++++++++----------
 drivers/net/dsa/mv88e6060.c      | 10 +++--
 drivers/net/dsa/mv88e6xxx/chip.c | 10 +++--
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                | 13 ++++---
 net/dsa/dsa.c                    | 22 ++++++-----
 net/dsa/hwmon.c                  |  2 +-
 9 files changed, 149 insertions(+), 77 deletions(-)

-- 
2.9.3

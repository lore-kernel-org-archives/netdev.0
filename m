From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: dsa: Preparatory patches
Date: Thu, 26 Jan 2017 10:28:04 -0800
Message-ID: <20170126182808.13435-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36052 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751747AbdAZShZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:37:25 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so22955703pgf.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:36:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series extracts the 4 patches of the larger: net: dsa: Support for
pdata in dsa2 while we wait for feedback from Greg KH on the device references.

Thanks!

Florian Fainelli (4):
  net: dsa: Pass device pointer to dsa_register_switch
  net: dsa: Make most functions take a dsa_port argument
  net: dsa: Suffix function manipulating device_node with _dn
  net: dsa: Move ports assignment closer to error checking

 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c | 11 ++---
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  2 +-
 net/dsa/dsa.c                    | 15 ++++---
 net/dsa/dsa2.c                   | 87 ++++++++++++++++++++++------------------
 net/dsa/dsa_priv.h               |  4 +-
 7 files changed, 67 insertions(+), 56 deletions(-)

-- 
2.9.3

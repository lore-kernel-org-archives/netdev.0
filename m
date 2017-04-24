From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: dsa: b53: BCM58xx devices fixes
Date: Mon, 24 Apr 2017 14:27:20 -0700
Message-ID: <20170424212723.15407-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoifairelinux.com,
        eric@anholt.net, jon.mason@broadcom.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34303 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978266AbdDXV13 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 17:27:29 -0400
Received: by mail-wm0-f67.google.com with SMTP id z129so20630548wmb.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 14:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains fixes for the 58xx devices (Broadcom Northstar
Plus), which were identified thanks to the help of Eric Anholt.

Florian Fainelli (3):
  net: dsa: b53: Include IMP/CPU port in dumb forwarding mode
  net: dsa: b53: Implement software reset for 58xx devices
  net: dsa: b53: Fix CPU port for 58xx devices

 drivers/net/dsa/b53/b53_common.c | 37 +++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/b53/b53_regs.h   |  5 +++++
 2 files changed, 40 insertions(+), 2 deletions(-)

-- 
2.9.3

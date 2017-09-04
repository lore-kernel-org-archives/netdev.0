From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 0/1] net: mdio-mux: add mdio_mux parameter to mdio_mux_init()
Date: Mon,  4 Sep 2017 18:30:13 +0200
Message-ID: <20170904163014.955-1-clabbe.montjoie@gmail.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com, rjui@broadcom.com,
        sbranden@broadcom.com, jonmason@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33182 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752687AbdIDQcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 12:32:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

For dwmac-sun8i, we need to set a MDIO mux which is not itself a device
(it is part of a device but have its own DT node)

This patch permit to use a MDIO mux for such case.
See agreement at https://lkml.org/lkml/2017/8/29/407

Since all mdio_mux_init() users are within drivers/net/phy/ and the changes are
trivial, I have done all in one patch, instead of having a complex series of
patch converting one by one callers.

This patch is a dependency for restoring dwmac-sun8i so it is why I target "net:"
But I send it alone, for be sure that this conversion in one patch is acceptable.

Regards

Corentin Labbe (1):
  net: mdio-mux: add mdio_mux parameter to mdio_mux_init()

 drivers/net/phy/mdio-mux-bcm-iproc.c | 2 +-
 drivers/net/phy/mdio-mux-gpio.c      | 2 +-
 drivers/net/phy/mdio-mux-mmioreg.c   | 3 ++-
 drivers/net/phy/mdio-mux.c           | 7 ++++---
 include/linux/mdio-mux.h             | 9 +++++++++
 5 files changed, 17 insertions(+), 6 deletions(-)

-- 
2.13.5

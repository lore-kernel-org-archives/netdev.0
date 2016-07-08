From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: dsa: b53: Add Broadcom NSP switch support
Date: Fri,  8 Jul 2016 11:39:11 -0700
Message-ID: <1468003153-14026-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jon.mason@broadcom.com, andrew@lunn.ch,
	zajec5@gmail.com, vivien.didelot@savoirfairelinux.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33304 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755954AbcGHSkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 14:40:19 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so8669214pac.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 11:39:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series updates the B53 driver to support Broadcom's Northstar Plus
Soc integrated switch.

Unlike the version of the core present in BCM5301x/Northstar, we cannot read the
full chip id of the switch, so we need to get the information about our switch
id from Device Tree.

Other than that, this is a regular Broadcom Ethernet switch which is register
compatible for all practical purposes with the existing switch driver.

Since DSA requires a working CPU Ethernet MAC driver this depends on Jon
Mason's AMAC/BGMAC driver changes to support NSP. Board specific changes depend
on patches present in Broadcom's ARM SoC branches and will be posted in a short
while.

Florian Fainelli (2):
  net: dsa: b53: Allow SRAB driver to specify platform data
  net: dsa: b53: Add support for BCM585xx/586xx/88312 integrated switch

 Documentation/devicetree/bindings/net/dsa/b53.txt |  9 +++++
 drivers/net/dsa/b53/b53_common.c                  | 12 ++++++
 drivers/net/dsa/b53/b53_priv.h                    |  1 +
 drivers/net/dsa/b53/b53_srab.c                    | 47 ++++++++++++++++++-----
 4 files changed, 59 insertions(+), 10 deletions(-)

-- 
2.7.4

From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Sat, 12 Mar 2016 00:08:44 +0100
Message-ID: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55231 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbcCKXJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:09:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, supporting a fixed-phy in a MAC driver is a bit messy. It
needs to be explicit supported, since a fixed phy is somewhat
different from a normal phy.

These two patches solve this by making fixed-phys appear as normal
PHYs within device tree, allowing them to be referenced by a phandle.
Any MAC driver that supports phy-handle can then automatically support
a fixed-phy without any code change.

Andrew Lunn (2):
  of: of_mdio: Factor out fixed-link parsing
  phy: fixed-phy: Allow DT description of an MDIO bus and PHYs.

 .../devicetree/bindings/net/fixed-link.txt         |  39 +++++++
 drivers/net/phy/fixed_phy.c                        | 122 ++++++++++++++++++++-
 drivers/of/of_mdio.c                               |  34 +++---
 include/linux/of_mdio.h                            |  11 +-
 4 files changed, 188 insertions(+), 18 deletions(-)

-- 
2.7.0

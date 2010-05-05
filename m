From: Sebastien Jan <s-jan@ti.com>
Subject: [PATCH 0/4 v2] ks8851: support for read/write MAC address from eeprom
Date: Wed,  5 May 2010 20:45:51 +0200
Message-ID: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Cc: linux-omap@vger.kernel.org, Abraham Arce <x0066660@ti.com>,
	Ben Dooks <ben-linux@fluff.org>, Tristram.Ha@micrel.com,
	Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provides the ability to update the ks8851 companion eeprom content (including the
MAC address) through ethtool or debugfs (for MAC address only).

Differences with v1:
 - added the support of eeprom access through ethtool
 - different patches split

Patch set tested on OMAP4-based test board. Build tested on net-2.6 head.

Applies on current net-2.6 head.

Sebastien Jan (4):
  ks8851: Add caching of CCR register
  ks8851: Low level functions for read/write to companion eeprom
  ks8851: companion eeprom access through ethtool
  ks8851: read/write MAC address on companion eeprom through debugfs

 drivers/net/ks8851.c |  570 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ks8851.h |   14 ++-
 2 files changed, 583 insertions(+), 1 deletions(-)


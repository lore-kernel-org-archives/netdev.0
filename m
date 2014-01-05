From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 0/5] bgmac: add initial support for core rev 4 on ARM BCM47xx
Date: Sun,  5 Jan 2014 01:10:42 +0100
Message-ID: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:60046 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754416AbaAEAKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 19:10:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for core rev 4 and ARM BCM47XX.
With an other fix to the platform code I am now getting over 200 MBit/s=
=20
with this Ethernet driver, the DMA problems are solved are unrelated
to bgmac.

v3:
   - moved flags calculation for bcma_core_enable() into if block
   - remove hard coding of phy address to BGMAC_PHY_NOREGS

v2: add changed suggested by Rafa=C5=82

Hauke Mehrtens (5):
  bcma: export bcma_find_core_unit()
  bgmac: initialize the DMA controller of core rev >=3D 4
  bgmac: add support for new BGMAC_CMDCFG_SR position on core rev >=3D =
4
  bgmac: reset all cores on Northstar SoC
  bgmac: add support for Northstar SoC (BCM4707, BCM53018)

 drivers/bcma/bcma_private.h           |    2 -
 drivers/bcma/main.c                   |   13 +---
 drivers/net/ethernet/broadcom/bgmac.c |  115 +++++++++++++++++++++++++=
+-------
 drivers/net/ethernet/broadcom/bgmac.h |   55 +++++++++++++++-
 include/linux/bcma/bcma.h             |    9 ++-
 5 files changed, 156 insertions(+), 38 deletions(-)

--=20
1.7.10.4

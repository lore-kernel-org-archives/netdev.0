From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: =?UTF-8?q?=5BPATCH=20v2=200/5=5D=20bgmac=3A=20add=20initial=20support=20for=20core=20rev=204=20on=20ARM=20BCM47xx?=
Date: Sat,  4 Jan 2014 19:13:53 +0100
Message-ID: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:59455 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656AbaADSOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 13:14:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for core rev 4 and ARM BCM47XX. I still have problems=
=20
with the DMA controller on the BCM4707 and I do not have a BCM53018.=20
Some packages are getting corrupted on TX, some are getting duplicated=20
on TX and so on on a BCM4707, I am still trying to fix this.

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
++------
 drivers/net/ethernet/broadcom/bgmac.h |   55 +++++++++++++++-
 include/linux/bcma/bcma.h             |    9 ++-
 5 files changed, 160 insertions(+), 34 deletions(-)

--=20
1.7.10.4

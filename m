From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 0/7] network driver fixes
Date: Fri, 29 Jan 2016 12:39:08 +0100
Message-ID: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:54860 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350AbcA2Ljw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 06:39:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an updated series of fixes for the network device drivers
that showed warnings in ARM randconfig.

Changes since v1 are:

dropped "net: macb: avoid uninitialized variables", already fixed in net-next

dropped "net: fddi/defxx: avoid warning about uninitialized variable
	use", already fixed in net-next

added missing barriers in "net: moxart: use correct accessors for
	DMA memory"

clarified "net: bgmac: clarify CONFIG_BCMA dependency" changelog


Arnd Bergmann (7):
  net: moxart: use correct accessors for DMA memory
  net: davinci_cpdma: use dma_addr_t for DMA address
  net: hp100: remove unnecessary #ifdefs
  net: bgmac: clarify CONFIG_BCMA dependency
  net: vxge: avoid unused function warnings
  net: nb8800: avoid uninitialized variable warning
  net: tg3: avoid uninitialized variable warning

 drivers/net/ethernet/aurora/nb8800.c           |  4 +--
 drivers/net/ethernet/broadcom/Kconfig          |  5 ++-
 drivers/net/ethernet/broadcom/tg3.c            |  2 +-
 drivers/net/ethernet/hp/hp100.c                | 18 ----------
 drivers/net/ethernet/moxa/moxart_ether.c       | 46 +++++++++++++++++---------
 drivers/net/ethernet/moxa/moxart_ether.h       |  4 +--
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 31 +++++++----------
 drivers/net/ethernet/ti/davinci_cpdma.c        | 12 +++----
 8 files changed, 57 insertions(+), 65 deletions(-)

-- 
2.7.0

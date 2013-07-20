From: Jonas Gorski <jogo@openwrt.org>
Subject: [PATCH 0/2] net: fix ixp4xx_eth
Date: Sat, 20 Jul 2013 12:15:37 +0200
Message-ID: <1374315339-31469-1-git-send-email-jogo@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Imre Kaloz <kaloz@openwrt.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset aims at fixing ethernet for ixp4xx, which is broken since
3.7. It is basedon discussion to the patch from Krzysztof Halasa [1],
following Russel King's suggestion.

This patchset is currently in use at OpenWrt and successfully tested
on Linksys NSLU2.

These patches are independent of each other, so they could go each in
a different tree or both in the same, and the order does not matter.

[1] https://patchwork.kernel.org/patch/2325151/

Jonas Gorski (2):
  arm: ixp4xx: set cohorent_dma_mask for ethernet platform devices
  net: ixp4xx_eth: use parent device for dma allocations

 arch/arm/mach-ixp4xx/fsg-setup.c         |  2 ++
 arch/arm/mach-ixp4xx/goramo_mlr.c        |  2 ++
 arch/arm/mach-ixp4xx/ixdp425-setup.c     |  3 +++
 arch/arm/mach-ixp4xx/nas100d-setup.c     |  1 +
 arch/arm/mach-ixp4xx/nslu2-setup.c       |  1 +
 arch/arm/mach-ixp4xx/omixp-setup.c       |  3 +++
 arch/arm/mach-ixp4xx/vulcan-setup.c      |  2 ++
 drivers/net/ethernet/xscale/ixp4xx_eth.c | 23 ++++++++++++-----------
 8 files changed, 26 insertions(+), 11 deletions(-)

-- 
1.8.3.2

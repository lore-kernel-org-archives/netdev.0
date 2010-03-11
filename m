From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 0/4] AM35xx : Add support for EMAC Peripheral
Date: Thu, 11 Mar 2010 20:43:38 +0530
Message-ID: <1268320422-32656-1-git-send-email-srk@ti.com>
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:44883 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932674Ab0CKPNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 10:13:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for EMAC peripheral on AM35xx
platform. The EMAC peripheral is borrowed from the DaVinci
platform and hence the same driver(davinci_emac) is used.

This patch series has been generated against tip of linux-omap and
depends on the following patches submitted to netdev/linux-davinci
list.

[1].http://patchwork.ozlabs.org/patch/47331/
[2].http://patchwork.ozlabs.org/patch/47332/

Sriramakrishnan (4):
  AM35xx EMAC : define submodule offsets.
  AM35xx : Platform specific hookup for EMAC module
  OMAP3 : clock data: Update name string for EMAC clocks.
  AM3517 defconfig update : enable EMAC support

 arch/arm/configs/am3517_evm_defconfig     |   70 ++++++++++++++++++++-
 arch/arm/mach-omap2/board-am3517evm.c     |   98 +++++++++++++++++++++++++++++
 arch/arm/mach-omap2/clock3xxx_data.c      |    4 +-
 arch/arm/mach-omap2/include/mach/am35xx.h |   11 +++-
 4 files changed, 179 insertions(+), 4 deletions(-)


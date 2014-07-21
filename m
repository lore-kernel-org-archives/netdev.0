From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 0/6] net: mvpp2: Assorted fixes
Date: Mon, 21 Jul 2014 13:48:10 -0300
Message-ID: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>,
	David Miller <davem@davemloft.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55238 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932679AbaGUQtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 12:49:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset contains a set of fixes for issues found while doing some
more intensive tests on the recently accepted mvpp2 ethernet driver.

David: if we are still in time, we'd like to get the driver fixes merged
for v3.17-rc1.

For the devicetree changes, it's already too late for that, since Jason
Cooper has already posted the PRs for v3.17. I'll re-post them when
v3.17-rc1 is released.

As usual, feedback is welcome.

Ezequiel Garcia (3):
  net: mvpp2: Fix the BM pool buffer release check
  net: mvpp2: Simplify BM pool buffers freeing
  ARM: mvebu: Add missing MDIO clock in Armada 375

Marcin Wojtas (3):
  net: mvpp2: Fix the periodic XON enable bit
  net: mvpp2: Enable proper PHY polling and fix port functionality
  ARM: mvebu: Add ethernet aliases required by U-Boot

 arch/arm/boot/dts/armada-375.dtsi    |  3 ++
 drivers/net/ethernet/marvell/mvpp2.c | 65 +++++++++++++++++++++++-------------
 2 files changed, 44 insertions(+), 24 deletions(-)

-- 
2.0.1

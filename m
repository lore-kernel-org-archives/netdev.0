From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 0/2] TI DaVinci EMAC: Add support for handling PHY Clock.
Date: Thu, 11 Mar 2010 19:54:49 +0530
Message-ID: <1268317491-3822-1-git-send-email-srk@ti.com>
Cc: nsekhar@ti.com, Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:39973 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab0CKOY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 09:24:59 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id o2BEOu0j008282
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 08:24:58 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to the EMAC module clock, the EMAC PHY clock needs to be 
managed separately. Until now, on most DaVinci platforms, the PHY clock
is always enabled. On AM35x platform where the same EMAC module is
used, the PHY clock needs to be managed explicitly. This patch 
series add support for handling PHY clock in the EMAC driver. Clock
definitions for platforms using the EMAC module have be modified
accordingly.

This patch series is generated against tip of Linus tree and depends
on the following patches submitted earlier

[1].http://patchwork.ozlabs.org/patch/47156/
[2].http://patchwork.ozlabs.org/patch/47303/

Sekhar Nori (1):
  davinci: introduce EMAC PHY clock usage

Sriramakrishnan (1):
  TI DaVinci EMAC: Add EMAC PHY clock handling.

 arch/arm/mach-davinci/board-da830-evm.c   |   19 +++++++++++++++++++
 arch/arm/mach-davinci/board-da850-evm.c   |   21 +++++++++++++++++++++
 arch/arm/mach-davinci/board-dm365-evm.c   |   18 ++++++++++++++++++
 arch/arm/mach-davinci/board-dm644x-evm.c  |   18 ++++++++++++++++++
 arch/arm/mach-davinci/board-dm646x-evm.c  |   15 +++++++++++++++
 arch/arm/mach-davinci/board-neuros-osd2.c |   19 +++++++++++++++++++
 arch/arm/mach-davinci/board-sffsdr.c      |   19 +++++++++++++++++++
 arch/arm/mach-davinci/da830.c             |    2 +-
 arch/arm/mach-davinci/da850.c             |    2 +-
 arch/arm/mach-davinci/dm365.c             |    2 +-
 arch/arm/mach-davinci/dm644x.c            |    2 +-
 arch/arm/mach-davinci/dm646x.c            |    2 +-
 drivers/net/davinci_emac.c                |   22 ++++++++++++++++++++--
 13 files changed, 154 insertions(+), 7 deletions(-)


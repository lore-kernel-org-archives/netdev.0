From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 0/3] TI EMAC driver : Make driver re-usable on non-davinci platforms.
Date: Wed, 18 Nov 2009 15:12:05 +0530
Message-ID: <1258537328-31527-1-git-send-email-srk@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:38918 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040AbZKRJmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 04:42:10 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by comal.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAI9gEnP007106
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 03:42:16 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Davinci EMAC peripheral is also available on other TI platforms -
notably TI AM3517 SoC. The following series of patches modify the driver 
suitably to make it platform agnostic.

Sriramakrishnan (3):
  TI Davinci EMAC : Re-use driver for other platforms.
  TI Davinci EMAC : add platform specific interrupt enable/disable
    logic.
  TI Davinci EMAC : Abstract Buffer address translation logic.

 arch/arm/mach-davinci/board-dm644x-evm.c    |    2 +-
 arch/arm/mach-davinci/board-dm646x-evm.c    |    2 +-
 arch/arm/mach-davinci/common.c              |    2 +-
 arch/arm/mach-davinci/include/mach/da8xx.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 arch/arm/mach-davinci/include/mach/emac.h   |   36 -----------------
 drivers/net/Kconfig                         |    2 +-
 drivers/net/davinci_emac.c                  |   55 +++++++++++++++++---------
 include/linux/davinci_emac.h                |   39 +++++++++++++++++++
 11 files changed, 83 insertions(+), 63 deletions(-)
 delete mode 100644 arch/arm/mach-davinci/include/mach/emac.h
 create mode 100644 include/linux/davinci_emac.h


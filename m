From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH-v2 0/3] TI EMAC driver : Make driver re-usable on non-davinci platforms.
Date: Thu, 19 Nov 2009 15:58:24 +0530
Message-ID: <1258626507-5570-1-git-send-email-srk@ti.com>
Cc: netdev@vger.kernel.org, Sriramakrishnan <srk@ti.com>
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60627 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756148AbZKSK23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 05:28:29 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAJASXW3011841
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 04:28:35 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Davinci EMAC peripheral is also available on other TI platforms -
notably TI AM3517 SoC. The following series of patches modify the driver 
suitably to make it platform agnostic.

This patch has been generated against the tip of linux-davinci git.

Sriramakrishnan (3):
  TI Davinci EMAC : Re-use driver for other platforms.
  TI Davinci EMAC : add platform specific interrupt enable/disable
    logic.
  TI Davinci EMAC : Abstract Buffer address translation logic.

 arch/arm/mach-davinci/common.c              |    2 +-
 arch/arm/mach-davinci/include/mach/da8xx.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 arch/arm/mach-davinci/include/mach/emac.h   |   36 -----------------
 drivers/net/Kconfig                         |    2 +-
 drivers/net/davinci_emac.c                  |   55 +++++++++++++++++---------
 include/linux/davinci_emac.h                |   39 +++++++++++++++++++
 9 files changed, 81 insertions(+), 61 deletions(-)
 delete mode 100644 arch/arm/mach-davinci/include/mach/emac.h
 create mode 100644 include/linux/davinci_emac.h


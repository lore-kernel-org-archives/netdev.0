From: <ganesanr@broadcom.com>
Subject: [PATCH 0/3] XLR/XLS network driver update and fixes
Date: Wed, 18 Jun 2014 18:43:55 +0530
Message-ID: <cover.1403096668.git.ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ganesan Ramalingam <ganesanr@broadcom.com>,
	<jchandra@broadcom.com>, <linux-mips@linux-mips.org>,
	<ralf@linux-mips.org>, <netdev@vger.kernel.org>
To: <kristina.martsenko@gmail.com>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:36942 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966138AbaFRMfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 08:35:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesan Ramalingam <ganesanr@broadcom.com>

Patches has following changes:

 * Fixed compilation failure caused by change in COP2 API
 * SGMII PHY address calculation was wrong, fixed
 * Updated the driver to have single parent device for a XLR/XLS
   network block with multiple network devices under it
 * Fixed comment format

Ganesan Ramalingam (3):
  Staging: Fix compilation error
  Staging: PHY address calculation fix
  Staging: Move all the netdev under single parent device per
    controller

 drivers/staging/netlogic/TODO           |    1 -
 drivers/staging/netlogic/platform_net.c |  213 ++++++++++++----------
 drivers/staging/netlogic/platform_net.h |    7 +-
 drivers/staging/netlogic/xlr_net.c      |  301 +++++++++++++++++--------------
 drivers/staging/netlogic/xlr_net.h      |    8 +-
 5 files changed, 292 insertions(+), 238 deletions(-)

-- 
1.7.9.5

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/2] sfc: I2C cleanup
Date: Fri, 30 May 2008 22:26:16 +0100
Message-ID: <20080530212615.GF1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jean Delvare <khali@linux-fr.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35678 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753339AbYE3V0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 17:26:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

These changes are for netdev-next.

Ben.

Ben Hutchings (2):
  sfc: Use kernel I2C system and i2c-algo-bit driver
  sfc: Reduce I2C udelay to 5 resulting in a clock frequency of 100 kHz

 drivers/net/sfc/Kconfig      |    2 +
 drivers/net/sfc/Makefile     |    2 +-
 drivers/net/sfc/boards.c     |    2 +-
 drivers/net/sfc/boards.h     |    3 +-
 drivers/net/sfc/efx.c        |    2 +
 drivers/net/sfc/falcon.c     |   74 ++++++---
 drivers/net/sfc/i2c-direct.c |  381 ------------------------------------------
 drivers/net/sfc/i2c-direct.h |   91 ----------
 drivers/net/sfc/net_driver.h |   11 +-
 drivers/net/sfc/sfe4001.c    |  126 ++++++++-------
 10 files changed, 134 insertions(+), 560 deletions(-)
 delete mode 100644 drivers/net/sfc/i2c-direct.c
 delete mode 100644 drivers/net/sfc/i2c-direct.h

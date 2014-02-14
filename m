From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 0/6] gianfar: Device configuration fixes
Date: Fri, 14 Feb 2014 14:03:59 +0200
Message-ID: <1392379445-28358-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:29412
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751584AbaBNMEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 07:04:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset represents the first part of an effort
to solve some old device configuration issues in gianfar,
especially run-time reset and re-configuration problems.
I'm referring to "on-the-fly" configuration of registers
against HW specification, concurrency issues during device
reset / re-configuration operations, and implementing HW
advisories for these operations.

There's also a good deal of code cleanup and refactoring,
and some other (minor) fixes as well.

Thank you. 


Claudiu Manoil (6):
  gianfar: Cleanup/Fix gfar_probe and the hw init code
  gianfar: Replace sysfs stubs with module params (fix)
  gianfar: Remove useless HAS_PADDING device flag
  gianfar: Factor out enabling/disabling of hw interrupts
  gianfar: Add missing graceful reset steps and fixes
  gianfar: Remove clean_rx_ring race from gfar_ethtool

 drivers/net/ethernet/freescale/Makefile          |   2 +-
 drivers/net/ethernet/freescale/gianfar.c         | 503 +++++++++++------------
 drivers/net/ethernet/freescale/gianfar.h         |  41 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  64 +--
 drivers/net/ethernet/freescale/gianfar_param.c   | 123 ++++++
 drivers/net/ethernet/freescale/gianfar_sysfs.c   | 340 ---------------
 6 files changed, 405 insertions(+), 668 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/gianfar_param.c
 delete mode 100644 drivers/net/ethernet/freescale/gianfar_sysfs.c

-- 
1.7.11.7

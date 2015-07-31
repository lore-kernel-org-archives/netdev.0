From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 0/3] gianfar: wol magic packet fixes
Date: Fri, 31 Jul 2015 18:38:30 +0300
Message-ID: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0113.outbound.protection.outlook.com ([207.46.100.113]:23872
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754052AbbGaPj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2015 11:39:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes were already validated as part of FSL SDK.
Patch 2 fixes occasional wake-on magic packet failures during
traffic, probably due to incorrect traffic stop/ device halt
sequence and incorrect usage of txlock.

Claudiu Manoil (3):
  gianfar: Fix warning when CONFIG_PM off
  gianfar: Fix suspend/resume for wol magic packet
  gianfar: Enable device wakeup when appropriate

 drivers/net/ethernet/freescale/gianfar.c         | 104 +++++++----------------
 drivers/net/ethernet/freescale/gianfar.h         |   3 -
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   5 +-
 3 files changed, 33 insertions(+), 79 deletions(-)

-- 
1.7.11.7

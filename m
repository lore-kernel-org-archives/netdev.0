From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 0/3] gianfar: ARM port driver updates (2/2)
Date: Fri, 13 Mar 2015 10:36:27 +0200
Message-ID: <1426235790-7011-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0130.outbound.protection.outlook.com ([157.56.110.130]:58035
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750874AbbCMIvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 04:51:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 2nd round of driver updates to make gianfar portable on ARM,
for the ARM based SoC that integrates eTSEC - "ls1021a".
The patches address the bulk of remaining endianess issues -
handling DMA fields (BD and FCB), and device tree properties.

Claudiu Manoil (2):
  gianfar: Make BDs access endian safe
  gianfar: Make FCB access endian safe

Jingchang Lu (1):
  gianfar: Consider dts property endianess on handling

 drivers/net/ethernet/freescale/gianfar.c | 202 ++++++++++++++++++-------------
 drivers/net/ethernet/freescale/gianfar.h |  32 +++--
 2 files changed, 138 insertions(+), 96 deletions(-)

-- 
1.7.11.7

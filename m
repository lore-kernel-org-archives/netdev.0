From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [PATCH 0/3] Patchset for gianfar ptp driver
Date: Mon, 22 Feb 2016 14:49:30 +0800
Message-ID: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0071.outbound.protection.outlook.com ([207.46.100.71]:63264
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753507AbcBVHbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 02:31:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to enable ptp support for ls1021a platform. The endianness
issue in gianfar driver and gianfar ptp driver must be fixed, and a 1588
timer node must be added into dts.

Yangbo Lu (3):
  ARM: dts: ls1021a: add 1588 timer node
  gianfar_ptp: fix endianness in get_of_u32()
  gianfar: fix endianness for hardware timestamp

 arch/arm/boot/dts/ls1021a.dtsi               | 12 ++++++++++++
 drivers/net/ethernet/freescale/gianfar.c     |  2 ++
 drivers/net/ethernet/freescale/gianfar_ptp.c |  2 +-
 3 files changed, 15 insertions(+), 1 deletion(-)

-- 
2.1.0.27.g96db324

From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v2, 0/3] Add PTP support for ls1021a platform
Date: Wed, 24 Feb 2016 17:26:53 +0800
Message-ID: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>,
	Andy Fleming <afleming@gmail.com>,
	"Kumar Gala" <galak@codeaurora.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0082.outbound.protection.outlook.com ([157.56.111.82]:26976
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751991AbcBXJfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 04:35:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to enable ptp support for ls1021a platform. The endianness
issue in gianfar driver and gianfar ptp driver must be fixed, and a 1588
timer node must be added into dts.

Changes for v2:
	- Modified commit message
	- Added more reviewers

Yangbo Lu (3):
  ARM: dts: ls1021a: add 1588 timer node
  gianfar_ptp: replace get_of_u32 with of_property_read_u32
  gianfar: fix endianness for hardware timestamp

 arch/arm/boot/dts/ls1021a.dtsi               | 12 ++++++++++++
 drivers/net/ethernet/freescale/gianfar.c     |  4 ++--
 drivers/net/ethernet/freescale/gianfar_ptp.c | 27 +++++++--------------------
 3 files changed, 21 insertions(+), 22 deletions(-)

-- 
2.1.0.27.g96db324

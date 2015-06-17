From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH v2 0/3] Fix Ethernet jumbo frames support for Armada 370 and 38x
Date: Wed, 17 Jun 2015 15:19:19 +0200
Message-ID: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:52593 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757007AbbFQNT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 09:19:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch series fixes the Ethernet jumbo frames support for the SoCs
Armada 370, 380 and 385. Unlike Armada XP, the Ethernet controller for
this SoCs don't support TCP/IP checksumming with a frame size larger
than 1600 bytes.

This patches should be applied to the -stable kernels 3.8 and onwards.

Changes since v1:
- Use a new compatible string for the Ethernet IP found in Armada XP
  SoCs (instead of using an optional property).
- Fix the issue for the Armada 380 and 385 SoCs as well.

Regards,

Simon

Simon Guinot (3):
  net: mvneta: introduce compatible string "marvell,armada-xp-neta"
  ARM: mvebu: update Ethernet compatible string for Armada XP
  ARM: mvebu: disable IP checksum with jumbo frames for Armada 370

 .../bindings/net/marvell-armada-370-neta.txt       |  2 +-
 arch/arm/boot/dts/armada-370-xp.dtsi               |  2 --
 arch/arm/boot/dts/armada-370.dtsi                  |  8 +++++++
 arch/arm/boot/dts/armada-xp-mv78260.dtsi           |  2 +-
 arch/arm/boot/dts/armada-xp-mv78460.dtsi           |  2 +-
 arch/arm/boot/dts/armada-xp.dtsi                   | 10 +++++++-
 drivers/net/ethernet/marvell/mvneta.c              | 27 +++++++++++++++++++++-
 7 files changed, 46 insertions(+), 7 deletions(-)

-- 
2.1.4

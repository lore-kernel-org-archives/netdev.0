From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/3] Add support for switch on Armanda 370 RD
Date: Wed,  5 Nov 2014 20:01:58 +0100
Message-ID: <1415214121-29286-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org,
	linux ARM <linux-arm-kernel@lists.infradead.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	tawfik@marvell.com, maxime.ripard@free-electrons.com,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49042 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbaKETDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 14:03:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for the switch chip found on the Marvell
370 RD board. The first patch extends the current mv88e6171 driver to
also support the mv88e6172. The second patch described the switch in
the device tree of the board, and the last patch enables require build
options in mvebu_v7_defconfig.

Davem should take patch #1
Jason Cooper should take patch #2 and #3.

Andrew Lunn (3):
  dsa: mv88e6171: Add support for mv88e6172
  mvebu: 370 RD: Add support for the switch
  mvebu: defconfig: Enable the mv88E6171 switch driver

 arch/arm/boot/dts/armada-370-rd.dts  | 49 ++++++++++++++++++++++++++++++++----
 arch/arm/boot/dts/armada-370-xp.dtsi |  2 +-
 arch/arm/configs/mvebu_v7_defconfig  |  2 ++
 drivers/net/dsa/Kconfig              |  6 ++---
 drivers/net/dsa/mv88e6171.c          |  5 +++-
 5 files changed, 54 insertions(+), 10 deletions(-)

-- 
2.1.3

From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 0/5] ks8851 DT updates
Date: Thu, 22 May 2014 14:00:08 -0700
Message-ID: <1400792413-21618-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	Nishanth Menon <nm@ti.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches properly documents the micrel ks8851 spi ethernet
controller, converts to devm_regulator_get_optional() to make error
paths slightly simpler, and finally adds supports for another
optional regulator and a reset gpio.

Stephen Boyd (5):
  devicetree: bindings: Document micrel vendor prefix
  devicetree: bindings: Properly document micrel ks8851 SPI chips
  net: ks8851: Use devm_regulator_get_optional()
  net: ks8851: Add optional vdd_io regulator and reset gpio
  net: ks8851: Add of match table

 .../devicetree/bindings/net/micrel-ks8851.txt      | 15 ++++-
 .../devicetree/bindings/vendor-prefixes.txt        |  1 +
 drivers/net/ethernet/micrel/ks8851.c               | 71 +++++++++++++++++++---
 3 files changed, 75 insertions(+), 12 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

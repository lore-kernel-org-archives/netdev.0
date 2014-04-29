From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Subject: [PATCH v3 0/2] net/phy: micrel: Add DT configuration support and
Date: Tue, 29 Apr 2014 11:33:23 +0200
Message-ID: <1398764005-23855-1-git-send-email-hchaumette@adeneo-embedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rdunlap@infradead.org, xobs@kosagi.com, davem@davemloft.net,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Adds DT configuration support for ksz9031
 - Renames micrel-ksz9021.txt to micrel-ksz90x1.txt and adds ksz9031 binding
   documentation

Changes since v2:
 - Merged together ksz9031_load_{clk,data,ctrl}_skew_values()
 - Added field length and number of fields prameter to account for registers
  specificities
 - Added binding documentation

Changes since v1:
 - Removed ksz9021 and ksz9031 fixup deletions from arch/arm/mach-imx/mach-imx6q.c

Hubert Chaumette (2):
  Add support for ksz9031 PAD skew configuration over devicetree.
  Update Micrel KSZ90x1 binding documentation

 .../devicetree/bindings/net/micrel-ksz9021.txt     |  49 ------
 .../devicetree/bindings/net/micrel-ksz90x1.txt     |  83 ++++++++++
 drivers/net/phy/micrel.c                           | 167 ++++++---------------
 3 files changed, 127 insertions(+), 172 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz90x1.txt

-- 
1.9.2

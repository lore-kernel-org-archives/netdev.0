From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Subject: [PATCH v4 0/2] net/phy: micrel: Add DT configuration support and documentation for KSZ9031
Date: Tue,  6 May 2014 09:40:15 +0200
Message-ID: <1399362017-25787-1-git-send-email-hchaumette@adeneo-embedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rdunlap@infradead.org, xobs@kosagi.com, davem@davemloft.net,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.adetelgroup.com ([94.247.26.71]:10155 "EHLO
	hbg-pa71.hmc-pa.adm" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934069AbaEFHlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 03:41:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - Adds DT configuration support for ksz9031
 - Renames micrel-ksz9021.txt to micrel-ksz90x1.txt and adds ksz9031 binding
   documentation

Changes since v3:
 - Rebased on net-next
Changes since v2:
 - Merged together ksz9031_load_{clk,data,ctrl}_skew_values()
 - Added field length and number of fields prameter to account for registers
  specificities
 - Added binding documentation
Changes since v1:
 - Removed ksz9021 and ksz9031 fixup deletions from arch/arm/mach-imx/mach-imx6q.c

Hubert Chaumette (2):
  Update Micrel KSZ90x1 binding documentation
  ARM: i.MX6: Add OF configuration support for ksz9031

 .../devicetree/bindings/net/micrel-ksz9021.txt     |  49 ----------
 .../devicetree/bindings/net/micrel-ksz90x1.txt     |  83 ++++++++++++++++
 drivers/net/phy/micrel.c                           | 106 ++++++++++++++++++++-
 3 files changed, 188 insertions(+), 50 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz90x1.txt

-- 
2.0.0.rc0

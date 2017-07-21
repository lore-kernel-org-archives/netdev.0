From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v2 0/4] RGMII RX and TX clock delays using Atheros 8035
Date: Fri, 21 Jul 2017 13:22:00 +0200
Message-ID: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "Zefir Kurtisi" <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:38553 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752048AbdGULw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 07:52:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1
- Drop support for disabling RX and TX clock delays
(it breaks some boards). Document the issues instead.
- Split the MAC patch in two unrelated parts
- Fix the vantage 1172 DTS

Marc Gonzalez (4):
  net: phy: at803x: Document RGMII RX and TX clock delay issues
  net: ethernet: nb8800: Set RGMII_MODE for all RGMII modes
  net: ethernet: nb8800: Fix RGMII TX clock delay setup
  ARM: dts: tango4: Add RGMII RX and TX clock delays

 arch/arm/boot/dts/tango4-vantage-1172.dts |  2 +-
 drivers/net/ethernet/aurora/nb8800.c      |  8 +++++---
 drivers/net/phy/at803x.c                  | 12 ++++++++++++
 3 files changed, 18 insertions(+), 4 deletions(-)

-- 
2.11.0

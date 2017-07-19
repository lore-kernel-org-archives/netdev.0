From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH 0/2] Atheros 803x PHY RGMII clock delays
Date: Wed, 19 Jul 2017 17:29:07 +0200
Message-ID: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
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
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:49504 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933173AbdGSPkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 11:40:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches address the quirks of the Atheros PHY, with respect
to RGMII RX and TX clock delays.

Once the PHY driver is fixed, the second patch fixes the ethernet
controller used on tango boards.

Marc Gonzalez (2):
  net: phy: at803x: Fix RGMII RX and TX clock delays setup
  net: ethernet: nb8800: Fix RGMII TX clock delay setup

 drivers/net/ethernet/aurora/nb8800.c |  8 +++++---
 drivers/net/phy/at803x.c             | 32 ++++++++++++++++++++++++--------
 2 files changed, 29 insertions(+), 11 deletions(-)

-- 
2.11.0

From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/2] amd-xgbe: Remove baseT workaround for fixed
 speeds
Date: Mon, 14 Jul 2014 14:05:40 -0500
Message-ID: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0206.outbound.protection.outlook.com ([207.46.163.206]:46681
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754870AbaGNTF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2014 15:05:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series expands the speed/duplex settings array in phy.c
to support additional media types. With this expansion the workaround
in the amd-xgbe driver to set/remove baseT media types based on whether
auto negotiation is enabled can be removed.

This patch series is based on net-next.

---

Tom Lendacky (2):
      phy: Expand phy speed/duplex settings array
      amd-xgbe: Remove the adjustments needed for fixed speed


 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   10 ----------
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    4 ----
 drivers/net/phy/phy.c                        |   22 +++++++++++++++++++++-
 3 files changed, 21 insertions(+), 15 deletions(-)

-- 
Tom Lendacky

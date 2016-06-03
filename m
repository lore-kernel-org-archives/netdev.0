From: John Crispin <john@phrozen.org>
Subject: [PATCH V4 0/4]  net-next: mediatek: improve phy support
Date: Fri,  3 Jun 2016 10:17:05 +0200
Message-ID: <1464941829-38712-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@openwrt.org>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current driver did not handle the RGMII delay modes and asymmetric flow
control properly. The mii_bus is not freed properly. Also add support for
fixed-phy allowing the driver to work on SoCs that have an internal gigabit
switch.

John Crispin (4):
  net-next: mediatek: use mdiobus_free() in favour of kfree()
  net-next: mediatek: fix gigabit and flow control advertisement
  net-next: mediatek: add fixed-phy support
  net-next: mediatek: properly handle RGMII modes

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   40 +++++++++++++++++++++++----
 1 file changed, 34 insertions(+), 6 deletions(-)

-- 
1.7.10.4

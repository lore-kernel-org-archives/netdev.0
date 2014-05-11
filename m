From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH 0/2] arc_emac: promiscuous/multicast mode and netpoll support
Date: Sun, 11 May 2014 18:11:46 +0200
Message-ID: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add support for promiscuous mode, multicast filtering
and netpoll to the ARC EMAC driver.

They were both tested on a Radxa Rock board which uses a ARC EMAC IP
core integrated in the Rockchip RK3188 SoC.

Beniamino Galvani (2):
  arc_emac: implement promiscuous mode and multicast filtering
  arc_emac: add netpoll support

 drivers/net/ethernet/arc/emac_main.c |   49 ++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

-- 
1.7.10.4

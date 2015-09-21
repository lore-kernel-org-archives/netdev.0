From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 0/4] Add support for reading macid when DT macid not found
Date: Mon, 21 Sep 2015 15:56:49 +0530
Message-ID: <1442831213-3913-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, <devicetree@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:54582 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbbIUK1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 06:27:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did a boot test on dra7-evm [1] and am437x-gp-evm [2].
Pushed a branch [3] for others to test the patch.

[1]: http://pastebin.ubuntu.com/12513420/
[2]: http://pastebin.ubuntu.com/12513428/
[3]: git://git.ti.com/~mugunthanvnm/ti-linux-kernel/linux.git cpsw-macid-read-support

Mugunthan V N (4):
  drivers: net: cpsw: davinci_emac: move reading mac id to common file
  drivers: net: cpsw-common: add support for reading mac address for
    dra7 and am437x platforms
  arm: dts: dra7: add syscon phandle to cpsw node
  arm: dts: am4372: add syscon phandle to cpsw node

 arch/arm/boot/dts/am4372.dtsi          |  1 +
 arch/arm/boot/dts/dra7.dtsi            |  1 +
 drivers/net/ethernet/ti/cpsw-common.c  | 64 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/ti/cpsw.c         | 11 +++---
 drivers/net/ethernet/ti/cpsw.h         |  3 +-
 drivers/net/ethernet/ti/davinci_emac.c | 44 ++---------------------
 6 files changed, 65 insertions(+), 59 deletions(-)

-- 
2.6.0.rc2.10.gf4d9753

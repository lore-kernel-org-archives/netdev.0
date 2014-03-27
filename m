From: <dinguyen@altera.com>
Subject: [PATCH net-next 0/3] net: stmmac: Add glue layer for socfpga platform
Date: Wed, 26 Mar 2014 22:45:09 -0500
Message-ID: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <srinivas.kandagatla@st.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <arm@kernel.org>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<devicetree@vger.kernel.org>, Dinh Nguyen <dinguyen@altera.com>
To: <dinh.linux@gmail.com>, <arnd@arndb.de>, <davem@davemloft.net>,
	<peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0148.outbound.protection.outlook.com ([65.55.169.148]:32158
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752984AbaC0DsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 23:48:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

Hi David,

I'm re-submitting the patch series to add the socfpga glue layer for the
stmmac ethernet driver. My original patch did not build for kernel module,
and I apologize for not testing against that.

This patch is also better aligned with the other stmmac glue
layers(sti and sunxi).

I'd like to take the "net: stmmac: Add SOCFPGA glue driver" patch into your
tree and the other 2 dts patches through the arm-soc tree.

Thanks,


Dinh Nguyen (3):
  net: stmmac: Add SOCFPGA glue driver
  dts: socfpga: Add DTS entry for adding the stmmac glue layer for
    stmmac.
  dts: stmmac: Document the clocks property in the stmmac base document

 .../devicetree/bindings/net/socfpga-dwmac.txt      |   27 ++++
 Documentation/devicetree/bindings/net/stmmac.txt   |    6 +
 arch/arm/boot/dts/socfpga.dtsi                     |    2 +
 arch/arm/boot/dts/socfpga_arria5_socdk.dts         |   21 ++++
 arch/arm/boot/dts/socfpga_cyclone5_socdk.dts       |   14 +++
 arch/arm/boot/dts/socfpga_cyclone5_sockit.dts      |   17 +++
 arch/arm/boot/dts/socfpga_vt.dts                   |    5 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   10 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  130 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    3 +
 12 files changed, 239 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socfpga-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c

-- 
1.7.9.5

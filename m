From: Oliver Graute <oliver.graute@gmail.com>
Subject: Micrel Phy KSZ8031 clock select setting in dts
Date: Fri, 17 Jun 2016 15:04:38 +0200
Message-ID: <20160617130438.GB6604@graute-opti>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, johan@kernel.org, bth@kamstrup.dk,
	s.hauer@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36323 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbcFQNFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 09:05:05 -0400
Received: by mail-wm0-f46.google.com with SMTP id f126so88338786wma.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 06:05:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I try to enable a Micrel KSZ8031 in my imx6ul board device tree. But i'am
struggeling with the setting for KSZPHY_RMII_REF_CLK_SEL BIT(7). In my
revision of this Micrel KSZ8031 Phy the Bit(7) has to be true. The 0x1f
register must be 0x8180.

How can I configure this register setting into my DTS?

I already checked Documentation/devicetree/bindings/net/micrel.txt

but i'am not sure if this still up to date. There where some reworks
after git commit 86dc1342

some other commits related to this Phy clock setting I checked

commit 1fadee0c3
commit b838b4aced

my non working device tree blob for the phy is:

&fec1 {
	pinctrl-names = "default";
	pinctrl-0 = <&pinctrl_enet1>;
	phy-mode = "rmii";
	rmmi-ref-clk-sel = <1>;
	phy-handle = <&ethphy0>;
	status = "okay";

	mdio {
		#address-cells = <1>;
		#size-cells = <0>;

		ethphy0: ethernet-phy@0 {
			compatible = "micrel,ksz8031";
			reg = <0>;
		};
	};
};


some clue how to configure this phy register setting correctly?

Best regards,

Oliver

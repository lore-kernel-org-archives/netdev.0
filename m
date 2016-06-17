From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Fri, 17 Jun 2016 16:48:05 +0300
Message-ID: <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
References: <20160617130438.GB6604@graute-opti>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, johan@kernel.org, bth@kamstrup.dk,
	s.hauer@pengutronix.de
To: Oliver Graute <oliver.graute@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35563 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbcFQNsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 09:48:10 -0400
Received: by mail-lf0-f48.google.com with SMTP id l188so58306656lfe.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 06:48:09 -0700 (PDT)
In-Reply-To: <20160617130438.GB6604@graute-opti>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2016 04:04 PM, Oliver Graute wrote:

> I try to enable a Micrel KSZ8031 in my imx6ul board device tree. But i'am
> struggeling with the setting for KSZPHY_RMII_REF_CLK_SEL BIT(7). In my
> revision of this Micrel KSZ8031 Phy the Bit(7) has to be true. The 0x1f
> register must be 0x8180.
>
> How can I configure this register setting into my DTS?
>
> I already checked Documentation/devicetree/bindings/net/micrel.txt
>
> but i'am not sure if this still up to date. There where some reworks
> after git commit 86dc1342
>
> some other commits related to this Phy clock setting I checked
>
> commit 1fadee0c3
> commit b838b4aced
>
> my non working device tree blob for the phy is:
>
> &fec1 {
> 	pinctrl-names = "default";
> 	pinctrl-0 = <&pinctrl_enet1>;
> 	phy-mode = "rmii";
> 	rmmi-ref-clk-sel = <1>;
> 	phy-handle = <&ethphy0>;
> 	status = "okay";
>
> 	mdio {
> 		#address-cells = <1>;
> 		#size-cells = <0>;
>
> 		ethphy0: ethernet-phy@0 {
> 			compatible = "micrel,ksz8031";
> 			reg = <0>;
> 		};
> 	};
> };
>
>
> some clue how to configure this phy register setting correctly?

    Tried specifying "micrel,rmii-reference-clock-select-25-mhz" property in 
the PHY node?

> Best regards,
>
> Oliver

MBR, Sergei

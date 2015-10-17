From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 17:38:59 +0200
Message-ID: <20151017153859.GA4763@lunn.ch>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
 <alpine.DEB.2.02.1510161749490.25648@linux-builds1>
 <20151016235042.GA28795@lunn.ch>
 <alpine.DEB.2.02.1510170920160.12375@linux-builds1>
 <alpine.DEB.2.02.1510171004080.31606@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42270 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbbJQPjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 11:39:01 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1510171004080.31606@linux-builds1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've also tried creating a separate phy node in the DTS and have the EMAC
> point the PHY with a 'phy = <&phy0>;', but that also didn't seem to work with
> your patch.

Do you have the phy node as a child of the mdio node?

Picking a random example arch/arm/boot/dts/kirkwood-rd88f6192.dts 

&mdio {
        status = "okay";

        ethphy0: ethernet-phy@8 {
                reg = <8>;
        };
};

&eth0 {
        status = "okay";
        ethernet0-port@0 {
                phy-handle = <&ethphy0>;
        };
};

	Andrew

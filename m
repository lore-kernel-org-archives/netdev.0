From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Sat, 12 Mar 2016 01:12:24 +0100
Message-ID: <20160312001224.GE23969@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <56E35432.2010300@gmail.com>
 <20160311233610.GB23969@lunn.ch>
 <56E35712.5080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55284 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751562AbcCLAMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 19:12:25 -0500
Content-Disposition: inline
In-Reply-To: <56E35712.5080508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> Humm, if that's the problem we want to solve, we could introduce a
> >> helper function which tries to locate the phy using a 'phy-handle'
> >> property
> > 
> > I don't follow you. Where do you get a phandle from to use with
> > phy-handle?
> 
> >From the caller of the function: the consumer of that phy-handle and/or
> fixed-link property which is either an Ethernet MAC driver or a DSA's
> switch port node.

I still don't get it. Lets take a real example. I currently have this
in one of my dts files:

&fec1 {
       phy-mode = "rmii";
       pinctrl-names = "default";
       pinctrl-0 = <&pinctrl_fec1>;
       status = "okay";

       fixed-link {
                  speed = <100>;
                  full-duplex;
       };
};

and we now want to use a phy-handle:

&fec1 {
       phy-mode = "rmii";
       pinctrl-names = "default";
       pinctrl-0 = <&pinctrl_fec1>;
       status = "okay";

       phy-handle = <XZY>;
};

What do i use as XZY, so that it somehow resolves to a fixed-phy?

Thanks
	Andrew

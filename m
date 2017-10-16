From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII
 bus
Date: Mon, 16 Oct 2017 14:40:02 +0200
Message-ID: <20171016124002.GE4255@lunn.ch>
References: <20171016104525.26810-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Martin =?iso-8859-1?Q?Hundeb=F8ll?= <mnhu@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:46324 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751358AbdJPMkG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 08:40:06 -0400
Content-Disposition: inline
In-Reply-To: <20171016104525.26810-1-mnhu@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>       /* internal MII */
>       mdio {
>         switch0phy1@1 {
>           reg = <1>;
>         };
>       };
> 
>       /* external MII */
>       mdio1 {
>         switch0phy0: switch0phy0@0 {
>           reg = <0>;
>         };

Hi Martin

You are missing a compatible string here. The binding document says:

- mdio?         : Container of PHYs and devices on the external MDIO
                          bus. The node must contains a compatible string of
                          "marvell,mv88e6xxx-mdio-external"

	  Andrew

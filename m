From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 22 Jan 2016 15:38:12 +0100
Message-ID: <20160122143812.GP9991@lunn.ch>
References: <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <569C9CD2.10301@gmail.com>
 <VI1PR04MB1664AB0E483F01F1641059FFE8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160118151500.GD923@lunn.ch>
 <VI1PR04MB1664DFBC53F08C5CE7EBF22AE8C10@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160121211250.GK9991@lunn.ch>
 <VI1PR04MB1664BAFB4EE494CB14830BCCE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56A1F5AB.6090606@gmail.com>
 <VI1PR04MB1664AD70D26C452F5A33595AE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <VI1PR04MB1664B669925ADB21D3A13594E8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <VI1PR04MB1664B669925ADB21D3A13594E8C40-mr6QIVyDiCHTAO9RNConP89NdZoXdze2vxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> The reason I mentioned maybe I should put the backplane property in
> fsl's binding is because the backplane implementation is really
> vendor specific, it's heavily relay how hardware implements the
> feature, maybe another vendor's hardware only needs a boolean
> property for driver to tell it should work in backplane, hardware
> can deal with different modes, or even no any special property
> needed if the hardware is strong enough to handle any connections, I
> cannot assume.  But I know what fsl's hardware needs to support
> backplane.

This is the key point really. We don't really care about the Freescale
PCS. We want a generic solution for 1000BASE-KX and 10GBASE-KR,
independent of who makes it, Marvell, Micrel, Broadcom, or Acme.

So, what generic properties are needed for 1000BASE-KX and 10GBASE-KR?
Properties that most/all manufactures are likely to need?

	   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

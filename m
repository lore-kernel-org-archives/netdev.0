From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1.1] net: emac: add support for device-tree based PHY
 discovery and setup
Date: Wed, 22 Feb 2017 15:37:35 -0500 (EST)
Message-ID: <20170222.153735.1289514443979947868.davem@davemloft.net>
References: <2109609d-c6a7-5c6f-d6aa-657107765778@gmail.com>
        <d32546b59c67456c77d003af1df51862d2f8c5de.1487617501.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ivan-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d32546b59c67456c77d003af1df51862d2f8c5de.1487617501.git.chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date: Mon, 20 Feb 2017 20:10:58 +0100

> This patch adds glue-code that allows the EMAC driver to interface
> with the existing dt-supported PHYs in drivers/net/phy.
> 
> Because currently, the emac driver maintains a small library of
> supported phys for in a private phy.c file located in the drivers
> directory.
> 
> The support is limited to mostly single ethernet transceiver like the:
> CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
> 
> However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
> have a 5-port switch (AR8327N) attached to the EMAC. The switch chip
> is supported by the qca8k mdio driver, which uses the generic phy
> library. Another reason is that PHYLIB also supports the BCM54610,
> which was used for the Western Digital My Book Live.
> 
> This will now also make EMAC select PHYLIB.
> 
> Signed-off-by: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

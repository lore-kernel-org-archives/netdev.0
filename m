From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Wed, 12 Jul 2017 15:40:15 +0200
Message-ID: <20170712134015.GA2557@lunn.ch>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
 <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <6de114cb-4521-4bb2-d0a3-4aea32936bd3@skidata.com>
 <AM4PR0401MB22609FFACD2BB51247709936FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <b68f444e-cea4-acaa-d1e9-7955a577ed35@skidata.com>
 <20170707140010.GD24237@lunn.ch>
 <e6b838e5-af7a-07be-42db-59b901cc04db@skidata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org" <dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org>
To: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e6b838e5-af7a-07be-42db-59b901cc04db-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> So would it be possible to add a "quick" bugfix patch (maybe this patch
> or another one removing the clk disable) so this fix can be backported
> to stable? Otherwise our board is only working with another
> "out-of-tree" patch (which I want to avoid)...

Hi Richard

It is a clear regression, so a minimal fix would be accepted to
stable.

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

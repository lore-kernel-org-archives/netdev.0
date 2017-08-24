From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 3/4] net: phy: realtek: add disable RX
 internal delay mode
Date: Thu, 24 Aug 2017 15:12:21 +0200
Message-ID: <20170824131221.GA8022@lunn.ch>
References: <20170822040400.12166-1-icenowy@aosc.io>
 <20170822040400.12166-4-icenowy@aosc.io>
 <20170822133906.GG24555@lunn.ch>
 <7c43220aef447e5cf21e48a9eca18535@aosc.io>
Reply-To: andrew-g2DYL2Zd6BY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: icenowy-h8G6r0blFSE@public.gmane.org
Return-path: <linux-sunxi+bncBDJNHL5JSEOBBOVB7PGAKGQE35YR5MI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <7c43220aef447e5cf21e48a9eca18535-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

> >Do we know that the TX lines do have a delay after making this change?
> >We need to be careful here. We will get into a mess if this is
> >actually RGMII not RGMII_TXID, and somebody designs a board which
> >needs RGMII-TXID.
> 
> In fact I'm not sure -- I'm even not sure that after making this change
> there's no TX delay. The change is totally not documented, so I choose
> to use a custom property in v1.

Can you get in touch with Realtek and ask? Or can you get a hardware
guy to do some measurements?

Thanks
    Andrew

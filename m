From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/3] net-next: stmmac: support future
 possible different internal phy mode
Date: Fri, 28 Jul 2017 16:44:24 +0200
Message-ID: <20170728144424.GB7221@Red>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com>
 <20170728135544.GD32230@lunn.ch>
 <20170728142508.GA7221@Red>
 <20170728143600.GB2132@lunn.ch>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	icenowy-h8G6r0blFSE@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBBUE35XFQKGQE7VTSH7I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170728143600.GB2132-g2DYL2Zd6BY@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 04:36:00PM +0200, Andrew Lunn wrote:
> > > I've probably asked this before: Does the internal PHY use a different
> > > PHY ID in registers 2 and 3?
> > > 
> > 
> > yes
> > 
> > reg2: 0x0044
> > reg3: 0X1500

Copy/paste error, its 1400

> 
> So this is not about loading the correct PHY driver. You can already
> do this based on the PHY IDs...
> 
> This is about selecting which PHY to use. Internal or External?	
> 
>      Andrew

It is too late when we know the PHY ID.
We need to set a syscon for choosing external/internal PHY.
So we can rely only on DT.

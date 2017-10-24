From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v7 10/10] of: mdio: Prevent
 of_mdiobus_register from scanning mdio-mux nodes
Date: Tue, 24 Oct 2017 21:02:26 +0200
Message-ID: <20171024190226.GA23866@Red>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
 <20171018114458.17891-11-clabbe.montjoie@gmail.com>
 <20171024184654.ggfrsrjd3nobku5n@rob-hp-laptop>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBBRU4X3HQKGQE5JDFV3Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20171024184654.ggfrsrjd3nobku5n@rob-hp-laptop>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 01:46:54PM -0500, Rob Herring wrote:
> On Wed, Oct 18, 2017 at 01:44:58PM +0200, Corentin Labbe wrote:
> > Each child node of an MDIO node is scanned as a PHY when calling
> > of_mdiobus_register() givint the following result:
> > [   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
> > [   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
> > [   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
> > [...]
> > [   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
> > [   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31
> > 
> > Since mdio-mux nodes are not PHY, this patch a way to to not scan
> > them.
> 
> This can be dropped now, right?

Yes and it is dropped in my two last serie.
Forgot to said it in changelog

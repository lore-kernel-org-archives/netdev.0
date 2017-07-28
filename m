From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 0/3] net-next: stmmac: support future
 possible different internal phy mode
Date: Fri, 28 Jul 2017 15:47:36 +0200
Message-ID: <20170728134736.GC32230@lunn.ch>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com>
 <CAGb2v66=h_5df=B0Us-kvvFg9r_qSUroDzn-xvQLSpD1d8DhBQ@mail.gmail.com>
Reply-To: andrew-g2DYL2Zd6BY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBDJNHL5JSEOBB7UA5XFQKGQEZUHRSRY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <CAGb2v66=h_5df=B0Us-kvvFg9r_qSUroDzn-xvQLSpD1d8DhBQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:53:40PM +0800, Chen-Yu Tsai wrote:
> On Fri, Jul 28, 2017 at 5:28 PM, Corentin Labbe
> <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hello
> >
> > The current way to find if the phy is internal is to compare DT phy-mode
> > and emac_variant/internal_phy.
> > But it will negate a possible future SoC where an external PHY use the
> > same phy mode than the internal one.
> >
> > This patchs series adds a new way to find if the PHY is internal, via its
> > compatible.
> 
> You've already joined in on the discussion for the patch "net: stmmac:
> dwmac-rk: Add internal phy support". It is pretty much the same issue.
> Please wait for it to come to a proper conclusion. At least then we can
> agree on something so different platforms with the same problem don't
> have diverging solutions.

Yes, this is important.

     Andrew

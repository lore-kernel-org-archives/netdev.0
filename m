From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 3/5] ARM: sun8i: dt: Add DT bindings
 documentation for Allwinner sun8i-emac
Date: Fri, 29 Jul 2016 20:12:32 +0200
Message-ID: <20160729181232.GF6215@lukather>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
 <1469001800-11615-4-git-send-email-clabbe.montjoie@gmail.com>
 <20160721075519.GC5993@lukather>
 <20160728134031.GC7582@Red>
 <20160728184916.GF6682@lukather>
 <20160729081519.GA31878@Red>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hK8Uo4Yp55NZU70L"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBBG5Z526AKGQE7PJNOOI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20160729081519.GA31878@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--hK8Uo4Yp55NZU70L
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

On Fri, Jul 29, 2016 at 10:15:19AM +0200, LABBE Corentin wrote:
> > > > > +See ethernet.txt in the same directory for generic bindings for ethernet
> > > > > +controllers.
> > > > > +
> > > > > +The device node referenced by "phy" or "phy-handle" should be a child node
> > > > > +of this node. See phy.txt for the generic PHY bindings.
> > > > > +
> > > > > +Optional properties:
> > > > > +- phy-supply: phandle to a regulator if the PHY needs one
> > > > > +- phy-io-supply: phandle to a regulator if the PHY needs a another one for I/O.
> > > > > +		 This is sometimes found with RGMII PHYs, which use a second
> > > > > +		 regulator for the lower I/O voltage.
> > > > > +- allwinner,tx-delay: The setting of the TX clock delay chain
> > > > > +- allwinner,rx-delay: The setting of the RX clock delay chain
> > > > 
> > > > In which unit? What is the default value?
> > > 
> > > The unit is unknown to me, but I have added a comment for the
> > > default and acceptable range value.
> > 
> > That's unfortunate. We'll see how the DT maintainers feel about that.
> > 
> 
> I have searched for txdelay in Documentation, and found a few driver
> that give the units (us/ps).
>
> But in that case, the value in ps/us must be found in a table
> indexed by the Xxdelay value.
>
> So the settings seems always a raw number, and for sun8i-emac
> nothing in user manual could help to find what each value is/related
> to.
> 
> So the good value is either found by "try and test" or "copy the
> value found in fex file".

What I meant was that, just like you found out already, most of the
time the properties should be in absolute units, so that it doesn't
depend on some clock rate most likely in that case.

Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--hK8Uo4Yp55NZU70L--

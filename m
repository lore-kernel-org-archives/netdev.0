From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 04/18] dt-bindings: syscon: Add DT
 bindings documentation for Allwinner syscon
Date: Thu, 20 Apr 2017 08:50:53 +0200
Message-ID: <20170420065053.GA28021@Red>
References: <20170412111400.2296-1-clabbe.montjoie@gmail.com>
 <20170412111400.2296-5-clabbe.montjoie@gmail.com>
 <9382f9ae-895a-397b-3d8c-846cb0bc4486@arm.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: =?iso-8859-1?Q?Andr=E9?= Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBBU5U4HDQKGQELM5GREA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <9382f9ae-895a-397b-3d8c-846cb0bc4486-5wv7dgnIgG8@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 12:38:50AM +0100, Andr=C3=A9 Przywara wrote:
> On 12/04/17 12:13, Corentin Labbe wrote:
> > This patch adds documentation for Device-Tree bindings for the
> > syscon present in allwinner devices.
> >=20
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  .../devicetree/bindings/misc/allwinner,syscon.txt     | 19 +++++++++++=
++++++++
> >  1 file changed, 19 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/misc/allwinner,sy=
scon.txt
> >=20
> > diff --git a/Documentation/devicetree/bindings/misc/allwinner,syscon.tx=
t b/Documentation/devicetree/bindings/misc/allwinner,syscon.txt
> > new file mode 100644
> > index 0000000..c056c5b
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/misc/allwinner,syscon.txt
> > @@ -0,0 +1,19 @@
> > +* Allwinner sun8i system controller
> > +
> > +This file describes the bindings for the system controller present in
> > +Allwinner SoC H3, A83T and A64.
> > +The principal function of this syscon is to control EMAC PHY choice an=
d
> > +config.
> > +
> > +Required properties for the system controller:
> > +- reg: address and length of the register for the device.
> > +- compatible: should be "syscon" and one of the following string:
> > +		"allwinner,sun8i-h3-system-controller"
> > +		"allwinner,sun8i-a64-system-controller"
>=20
> While sun8i might make some sense technically, all 64-bit sunxi
> compatible strings use the sun50i prefix to follow the Allwinner naming.
> So this should read:
> 		"allwinner,sun50i-a64-system-controller"
>=20
> Also I am wondering if we should add a compatible string for the H5
> (support for that SoC is in -next already):
> 		"allwinner,sun50i-h5-system-controller"
>=20
> Cheers,
> Andre.
>=20

I agree with sun50i-a64-system-controller, the sun8i-a64 is a copy/paste er=
ror.
I will add sun50i-h5-system-controller since all xxx-system-controller are =
just hypothetic compatible.

Thanks
Regards

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.

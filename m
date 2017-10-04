From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 1/2] dt-bindings: add device tree binding
 for Allwinner XR819 SDIO Wi-Fi
Date: Wed, 4 Oct 2017 12:11:45 +0200
Message-ID: <20171004101145.kgjufpcktodppuy3@flea>
References: <20171003165944.13056-1-icenowy@aosc.io>
 <20171003165944.13056-2-icenowy@aosc.io>
 <871smjxp46.fsf@kamboji.qca.qualcomm.com>
 <E46F3A20-294A-497E-AF71-C77A67AFDB8C@aosc.io>
 <59D4B1C8.8020105@broadcom.com>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z5ahan4c2wuj2t6k"
Cc: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBBZHH2LHAKGQEI4XFYIA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <59D4B1C8.8020105-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--z5ahan4c2wuj2t6k
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 04, 2017 at 10:02:48AM +0000, Arend van Spriel wrote:
> On 10/4/2017 11:03 AM, Icenowy Zheng wrote:
> >=20
> >=20
> > =E4=BA=8E 2017=E5=B9=B410=E6=9C=884=E6=97=A5 GMT+08:00 =E4=B8=8B=E5=8D=
=885:02:17, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> =E5=86=99=E5=88=B0:
> > > Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org> writes:
> > >=20
> > > > Allwinner XR819 is a SDIO Wi-Fi chip, which has the functionality t=
o
> > > use
> > > > an out-of-band interrupt pin instead of SDIO in-band interrupt.
> > > >=20
> > > > Add the device tree binding of this chip, in order to make it
> > > possible
> > > > to add this interrupt pin to device trees.
> > > >=20
> > > > Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
> > > > Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > > > ---
> > > > Changes in v3:
> > > > - Renames the node name.
> > > > - Adds ACK from Rob.
> > > > Changes in v2:
> > > > - Removed status property in example.
> > > > - Added required property reg.
> > > >=20
> > > >   .../bindings/net/wireless/allwinner,xr819.txt      | 38
> > > ++++++++++++++++++++++
> > > >   1 file changed, 38 insertions(+)
> > > >   create mode 100644
> > > Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> > >=20
> > > Like I asked already last time, AFAICS there is no upstream xr819
> > > wireless driver in drivers/net/wireless directory. Do we still accept
> > > bindings like this for out-of-tree drivers?
> >=20
> > See esp8089.
> >=20
> > There's also no in-tree driver for it.
>=20
> The question is whether we should. The above might be a precedent, but it
> may not necessarily be the way to go. The commit message for esp8089 seem=
s
> to hint that there is intent to have an in-tree driver:
>=20
> """
>     Note that at this point there only is an out of tree driver for this
>     hardware, there is no clear timeline / path for merging this. Still
>     I believe it would be good to specify the binding for this in tree
>     now, so that any future migration to an in tree driver will not cause
>     compatiblity issues.
>=20
>     Cc: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>     Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>     Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> """
>=20
> Regardless the bindings are in principle independent of the kernel and ju=
st
> describing hardware. I think there have been discussions to move the
> bindings to their own repository, but apparently it was decided otherwise=
.

Yeah, I guess especially how it could be merged with the cw1200 driver
would be very relevant to that commit log.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.

--z5ahan4c2wuj2t6k
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZ1LPhAAoJEBx+YmzsjxAg2YUQAJMxy9OzeXuAwzmK4xUR24Jo
Qa/0A+F6F6LzksbVJKLywrRFSEsJ6i++SUzZYygz6jMwwQl7OApg4Dj/qd+2jK/Q
LpgzeyXzgkcpOz2SHGeZZGiGn4YHVt/o1xSEkp2TWarL0iJ1Ckyt51Rs/fq2suoE
qJr/dgyIDR3ZW3ek2Z2JcANCJ3y0q4KdD9lYCiB9ZBSHDs02ksleD5K/7gBArX7B
tk+j+RK6r4A+UhnIC4T1GjWmcJRIkqAjjuaxFE4cFuKa2UvT2yKfoty9KHGfjgrU
Sd71nqBe654ADx3f7nAgH3RehgNlY+JV/2LAW0WWCv+vgB4rFlMZicKNm1XQXFsZ
/qM++w6bzAVyfiRXosOVtBOx7ocTHA2gNkyZT/Eh7PMn9Yt6ftMROL98S23eaXhE
ONjFoIt6HyCU+wu5Kka1L9YizE0dHT4l/hBu4m3j7OEgZaTg+wJflDlNvemuA/AD
jdOcM85UJM1azqjO7MmaaCF8UKQYgAHfiyh3j8vhPNjJ4TvNaMXri622a2ZojWJE
aj0Za2DzNmHSwrlU9CuItNS6WSwphtH3t65LLi/2uxsZUOr0hYdV5uNE1A1n6g1X
m9YAaDshKu4fBYpT9c9guWrET18OKcgxq+SZT3WrXgriVqYtEB6dxEe/gbp9c+lW
mJZBjzQkNFJepMq8fggE
=FjDQ
-----END PGP SIGNATURE-----

--z5ahan4c2wuj2t6k--

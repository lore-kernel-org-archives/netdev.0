From: "maxime.ripard" <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: Re: [PATCH 7/7] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Fri, 18 Apr 2014 19:47:24 +0200
Message-ID: <20140418174724.GG4132@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-8-git-send-email-wens@csie.org>
 <20140415144215.GG3207@lukather>
 <CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA@mail.gmail.com>
 <20140416094428.GK3207@lukather>
 <CAGb2v67HzB22a3huRRZyufXkdTFE410MhXqAHyC-MmVo0-GCFA@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SdvjNjn6lL3tIsv0"
Cc: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	"linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBO7YYWNAKGQE3HNH33Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v67HzB22a3huRRZyufXkdTFE410MhXqAHyC-MmVo0-GCFA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--SdvjNjn6lL3tIsv0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 16, 2014 at 06:39:28PM +0800, Chen-Yu Tsai wrote:
> Hi,
>=20
> On Wed, Apr 16, 2014 at 5:44 PM, Maxime Ripard
> <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> > Hi,
> >
> > Please try to keep me in CC, even though the ML doesn't make it easy..
>=20
> Sorry about that.
>=20
> > On Wed, Apr 16, 2014 at 12:06:59AM +0800, Chen-Yu Tsai wrote:
> >> >> @@ -139,4 +152,16 @@
> >> >>       reg_usb2_vbus: usb2-vbus {
> >> >>               status =3D "okay";
> >> >>       };
> >> >> +
> >> >> +     rfkill_bt {
> >> >> +             compatible =3D "rfkill-gpio";
> >> >> +             pinctrl-names =3D "default";
> >> >> +             pinctrl-0 =3D <&bt_pwr_pin_cubietruck>, <&clk_out_a_p=
ins_a>;
> >> >> +             clocks =3D <&clk_out_a>;
> >> >> +             clock-frequency =3D <32768>;
> >> >> +             gpios =3D <&pio 7 18 0>; /* PH18 */
> >> >> +             gpio-names =3D "reset";
> >> >> +             rfkill-name =3D "bt";
> >> >> +             rfkill-type =3D <2>;
> >> >> +     };
> >> >
> >> > Hmmm, I don't think that's actually right.
> >> >
> >> > If you have such a device, then I'd expect it to be represented as a
> >> > full device in the DT, probably with one part for the WiFi, one part
> >> > for the Bluetooth, and here the definition of the rfkill device that
> >> > controls it.
> >>
> >> The AP6210 is not one device, but 2 separate chips in one module. Each
> >> chip has its own controls and interface. They just so happen to share
> >> the same enclosure. Even 2-in-1 chips by Broadcom have separate contro=
ls
> >> and interfaces. The WiFi side is most likely connected via SDIO, while
> >> the Bluetooth side is connected to a UART, and optionally I2S for soun=
d.
> >
> > It's even easier to represent then.
> >
> >> > But tying parts of the device to the rfkill that controls it, such as
> >> > the clocks, or the frequency it runs at seems just wrong.
> >>
> >> I understand where you're coming from. For devices on buses that requi=
re
> >> drivers (such as USB, SDIO) these properties probably should be tied to
> >> the device node.
> >>
> >> For our use case here, which is a bluetooth chip connected on the UART,
> >> there is no in kernel representation or driver to tie them to. Same go=
es
> >> for UART based GPS chips. They just so happen to require toggling a GP=
IO,
> >> and maybe enabling a specific clock, to get it running. Afterwards,
> >> accessing it is done solely from userspace. For our Broadcom chips, the
> >> user has to upload its firmware first, then designate the tty as a Blu=
etooth
> >> HCI using hciattach.
> >>
> >> We are using the rfkill device as a on-off switch.
> >
> > I understand your point, but the fact that it's implemented in
> > user-space, or that UART is not a bus (which probably should be), is
> > only a Linux specific story, and how it's implemented in Linux (even
> > if the whole rfkill node is another one, but let's stay on topic).
>=20
> I gave it some thought last night. You are right. My whole approach
> is wrong. But let's try to make it right.
>=20
> So considering the fact that it's primarily connected to a UART,
> maybe I should make it a sub-node to the UART node it's actually
> connected to? Something like:
>=20
>         uart2: serial@01c28800 {
>                 pinctrl-names =3D "default";
>                 pinctrl-0 =3D <&uart2_pins_a>;
>                 status =3D "okay";
>=20
>                 bt: bt_hci {
>                         compatible =3D "brcm,bcm20710";
>                         /* maybe add some generic compatible */
>                         pinctrl-names =3D "default";
>                         pinctrl-0 =3D <&clk_out_a_pins_a>,
> <&bt_pwr_pin_cubietruck>;
>                         clocks =3D <&clk_out_a>;
>                         clock-frequency =3D <32768>;
>                         gpios =3D <&pio 7 18 0>; /* PH18 */
>                 };
>         };
>=20
> And let the uart core handle power sequencing for sub-nodes.
>=20
> The rfkill node would still have the gpios and clocks, but not the
> clock-frequency property. It's sole purpose would be to toggle the
> controls. But I think the placement is still odd. Perhaps these
> virtual devices shouldn't live in the DT at all.

Yes, it looks much better.

I agree with you on the virtual devices things, and we have a lot of
other examples unfortunately.

However, since the rfkill nodes are in the DT, I think you'd still
have a rfkill node to handle the gpio, and a reference to the killed
device of some sort.

As far as the clock is concerned, I don't know if it makes sense to
have the BT clock in the RF kill node.

You probably want to use it to gate it whenever the device is killed,
but if the device is setting the frequency, it will more likely hold a
reference to that clock, so calling the disable in rfkill won't do
much.

Is rfkill sending any notification of some sort that the device is
being killed?

> > This is a huge abstraction leak.
> >
> > Let's say you need the I2S stream you mentionned for some
> > reason. Would you tie the audio stream to the rfkill node as well?
> > I'm sorry, but from an hardware description perspective, it makes no
> > sense.
>=20
> The above revision should be better, from a hardware perspective. I'm
> not sure how to tie in the I2S stream, and there I haven't found any
> examples in the DT tree.

If it acts like an I2S "consumer", you can use ASoC's simple-card, and
you have a few examples in the other DTs.

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--SdvjNjn6lL3tIsv0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIbBAEBAgAGBQJTUWUrAAoJEBx+YmzsjxAg7FwP+MF7y+W6yH8NCw8ra2wzlxCv
z4kkKC26PekxHpcMfXfcGyWZgVa7D9pud1cK0SJe4SWZoXpzyc3XZF7L3H70o5YI
QrP4ZQZOCnsyP2yqug8Ks1cjfOzPXx2znFmzi11x4YMRlsrIovVC1ez8mw6p3V/o
VqCQtKAm+ZQmc5bZ30ize+mNrsVraiZee7ODikSLCjCLfu3Y2/miVtYSgp2xE0ip
ST24De9Yi9+1KLtUHCCNlK83Q376qqHM2uKBCm5CcFrqYaL1py+QOOn/NI48n8Cj
K7XkWT2rMQSVfo4Pd238uw29nO10R+1MCIiEHBYD+lED1CUY7cqWYb4jFHEEpL37
+SYXQmGDYmF+IgjPUZisGftJp4OxZraKG46rUFWWp43mJnvZP3ulRmu/zufoYpBH
bTqd3lQaKP76hQSmJxUyR+xgKnpgVJI107tvZzWeWwxLwmjuVo/ktUDEczGjUa2e
pWE72wM6XL7Ink15CBnXQ4XfHM9Odb7y0nPX6qDoT9yIUd1k+7hA04VfIKhHdLR4
y5cBEO6sgNlOjE3qYwJfYm6NPinyWn3tho8w5WVIbZM8CbCFA28DHD/cU1IuPoW4
M/VIxF0BTcKVnfC8muphSjOv3AYxDNS6868kw1WtzqynPRdK1rzc2uQfoUl/ki1I
jUxGpY+PqFdEf/iHE48=
=+Z9L
-----END PGP SIGNATURE-----

--SdvjNjn6lL3tIsv0--

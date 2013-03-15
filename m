From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net,stable-3.8] net: cdc_ncm, cdc_mbim: allow user to
 prefer NCM for backwards compatibility
Date: Fri, 15 Mar 2013 05:22:25 +0000
Message-ID: <1363324945.3937.144.camel@deadeye.wl.decadent.org.uk>
References: <1363259113-6909-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-w7sMNTl3HtbzxBRBuu27"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363259113-6909-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-w7sMNTl3HtbzxBRBuu27
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-03-14 at 12:05 +0100, Bj=C3=B8rn Mork wrote:
> commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBIM devices=
")
> introduced a new policy, preferring MBIM for dual NCM/MBIM functions if
> the cdc_mbim driver was enabled.  This caused a regression for users
> wanting to use NCM.
>=20
> Devices implementing NCM backwards compatibility according to section
> 3.2 of the MBIM v1.0 specification allow either NCM or MBIM on a single
> USB function, using different altsettings.  The cdc_ncm and cdc_mbim
> drivers will both probe such functions, and must agree on a common
> policy for selecting either MBIM or NCM.  Until now, this policy has
> been set at build time based on CONFIG_USB_NET_CDC_MBIM.
>=20
> Use a module parameter to set the system policy at runtime, allowing the
> user to prefer NCM on systems with the cdc_mbim driver.
>=20
> Cc: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
> Cc: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
> Reported-by: Geir Haatveit <nospam-br728iSPf5UsCylrc8G9yg@public.gmane.org>
> Reported-by: Tommi Kyntola <kynde-oSY6wnT0nbj1KXRcyAk9cg@public.gmane.org>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D54791
> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
>=20
> We now have two users independently reporting this as a 3.8 regression,
> so something needs to be done.  I am not sure if adding a new module
> parameter is acceptable for stable, but this problem is definitely a
> regression and no other solutions came up in response to my RFC.
>=20
> The only real alternative I see for stable, is disabling MBIM support
> on any dual NCM/MBIM function.  Which of course will be a regression
> for any user wanting MBIM, making it unacceptable.
[...]

It definitely makes sense for this to be a run-time parameter.  And the
default seems correct for custom kernels.

For a distribution kernel - at least for Debian, where we can't assume
kernel and userland are always updated together - I think the
compile-time default should be false, and the userland package
(presumably ModemManager?) can install a modprobe.conf file to override
that once it can handle MBIM.  We handled KMS transitions in a similar
way.  I don't know that it's worth having a Kconfig option for that,
though.

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-w7sMNTl3HtbzxBRBuu27
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUUKwEee/yOyVhhEJAQr0Jg/+KJYVjRo44djD1Be0hH0rgRQ6rGUZ4DFP
CneznTNXOU3tdOQ00wSHsgTkEQFYftuzjnt6FCic/OFLgVUU1syR1DjGrQdiPS81
oc/01FIDj5Vh5lgzHrfVWYT/7b+pAvEGmxGaG+9LvMLm6rtsHRxWs4UEG/uDXr4k
4kcCUZsak5VtbPfhdX4jjttjqMQ45UwfYUHci5jyH1DvfnwCdu2W99nTyNge1bei
vgMORYz0JfTXPsthBwb2iCLqfjI91dKDDU1EY3QLZu/EYLl3UIrhUK2NyW51NHUs
22iCEWz/kK1V0WIiT4qYJZ7p3OQyPaDP6ZGSURYu8EtOlq/nzLSR20nrBY7h165l
xfczvXsbzjslXNYAbWxN9GYy8xrBkz8Yz1l945ov+4RHDh0RmStlcFKqTpwynw+d
hmHaZW9S4H1BZZJDL08nhAH5IpjOUNce9OPCRx7ITzXrSNvFUzL9KT9ps7TvGMhS
IukS8mZ5ahKOMcvZiurhHYsJBsoXh1r6J7/FvBp+21OBho0/Tsn36fi2Tq7/riXK
t5+V0jgAPIMZUXHJB+Rb4vAQ3TPo51FIpSG7+1RRvasw+gfBaKCcn5vgHx2ZRVof
MNBT3lurXj3UejJA4zyhD4rievw8izx32GVVr9A/hr4VFTxg28oznDZOv4dEmZYK
+GhO1/vS6yg=
=WoOr
-----END PGP SIGNATURE-----

--=-w7sMNTl3HtbzxBRBuu27--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

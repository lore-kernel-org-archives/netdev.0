From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next 10/31] cxgb4/iw_cxgb4: Doorbell Drop Avoidance
 Bug Fixes.
Date: Tue, 04 Mar 2014 23:22:46 +0000
Message-ID: <1393975366.16256.23.camel@deadeye.wl.decadent.org.uk>
References: <1393427230-14532-11-git-send-email-hariprasad@chelsio.com>
	 <20140226.181216.1563503549713890339.davem@davemloft.net>
	 <005101cf33df$00749e40$015ddac0$@opengridcomputing.com>
	 <20140227.130544.1892840202381139797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VrBSJ10Vsu96RABSTkuV"
Cc: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140227.130544.1892840202381139797.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VrBSJ10Vsu96RABSTkuV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-27 at 13:05 -0500, David Miller wrote:
> From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> Date: Thu, 27 Feb 2014 11:11:49 -0600
>=20
> >>=20
> >> > -static int allow_db_fc_on_t5;
> >> > -module_param(allow_db_fc_on_t5, int, 0644);
> >> > -MODULE_PARM_DESC(allow_db_fc_on_t5,
> >> > -           "Allow DB Flow Control on T5 (default =3D 0)");
> >> > -
> >> > -static int allow_db_coalescing_on_t5;
> >> > -module_param(allow_db_coalescing_on_t5, int, 0644);
> >> > -MODULE_PARM_DESC(allow_db_coalescing_on_t5,
> >> > -           "Allow DB Coalescing on T5 (default =3D 0)");
> >>=20
> >> Module parameters are a user facing interface.
> >>=20
> >> You cannot just delete, or change the semantics of, the ones you feel
> >> like doing so to.
> >=20
> > I see your point on user facing interfaces.   These module params were
> > added initially to allow tweaking the db drop recovery for T5 devices i=
n
> > the thought that we might need it.  It turns out T5 doesn't suffer from
> > this issue.  These params default to 0 anyway, and I doubt anyone has
> > changed them.  Disabling the hw db coalescing feature proved problemati=
c
> > and it turned out to even make the issue worse, so I removed it totally
> > at the recommendation from the HW engineers, and put in place the new
> > design which better rate controls things under heavy load.
>=20
> You have to keep the old ones around.

Setting an unknown module parameter now results in a warning (since
3.11), so removing a parameter isn't so disruptive as it used to be.

Obviously this is removing a feature, but as the feature sounds like it
was only marginally useful I think it's a perfectly valid change.

Ben.

--=20
Ben Hutchings
I'm always amazed by the number of people who take up solipsism because
they heard someone else explain it. - E*Borg on alt.fan.pratchett

--=-VrBSJ10Vsu96RABSTkuV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxZgRue/yOyVhhEJAQqRfg//YcVaXxtS7anC0xctozIg7Cvx1u5jhcYz
wWjtdu0B2SN3WWcAYnm1Chj0LQy7B5HEfWyBD5rBx8LzTCquK/OW4J3e9Mopy8E+
Xk+VgbblOfbITHkua4592MSxzBq/8JQ0aSMe8Qfb4gW3uR6quJhVTunwEwSyiWdv
OcZ2FB52atc1iWVZdgNeMkPALn6s+2YgPNMqRCTpeiUtm/jVDPcGUDRNV/c0d9S9
VKM2N6UQsXReLWwNmfwa0MCzhV1oAw29GNqP64iwY2zpCIkxG4Gt3vZWGkfohmjz
NBIEoFiqNe13eC/x8li771ABfnskzcrSwh0pwI+GSK7L+I/T0Jo3Xo6m7sJyzXo0
pZ682Ni3HA70rXhLpJp96PONH1zFDo1bkH3YGrALkDnfU6gKAJYw3ejeuqjWQZ83
jXIRuN/byXPj1fadbbqvxbC2aRNfIsHWU4ruTw1wdY6x3YpgyZ+08l9DO2FU9jm7
Sx3gzeygz5ardGe/7g710oXbqcM3g8qPQnM8YvIrs0vBbexvs8w/wnKu/hcRFaO4
N30pRNpZb+eNraSQIw/iw3RfbXJy3M18rFo+chKuLRaGw7mpQw+/f7be/EJeNKZY
pcblXgctIORhjZxTeXPUElSqmUHRpgeNyKzeiHM14PaPm697GbI5oj3C80a4NBd1
Ot156Xc0Ehs=
=4YT0
-----END PGP SIGNATURE-----

--=-VrBSJ10Vsu96RABSTkuV--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

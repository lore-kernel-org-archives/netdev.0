From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] allow device to stop packet mirror behaviour
Date: Wed, 08 Aug 2007 11:14:01 +0200
Message-ID: <1186564441.11717.5.camel@johannes.berg>
References: <1186475155.4067.17.camel@johannes.berg>
	 <20070807.180607.116354128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zqmS7C6YYBPr5fhexhkT"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070807.180607.116354128.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-zqmS7C6YYBPr5fhexhkT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-08-07 at 18:06 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Tue, 07 Aug 2007 10:25:55 +0200
>=20
> > The only way to solve this problem therefore seems to be to suppress th=
e
> > mirroring out of the packet by dev_queue_xmit_nit(). The patch below
> > does that by way of adding a new netdev flag.
>=20
> Multicast packets also get looped back in a similar manner in the ipv4
> code.  These will also be seen twice due to this issue.

I don't think these other places are of any interest because of the
radiotap+802.11 framing on the devices where it is relevant to us; you
can't actually add an IP route to a monitor interface as far as I can
tell.

johannes

--=-zqmS7C6YYBPr5fhexhkT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGuYlZ/ETPhpq3jKURAlZTAJ4vllyzg0QZCC6vIPFcUoBnfTCndgCgnLR8
dY0FGxSmBgMolwL3nMAI3z8=
=fAR9
-----END PGP SIGNATURE-----

--=-zqmS7C6YYBPr5fhexhkT--

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-2.6 3/7] ixgbe: fix for 82599 erratum on Header
	Splitting.
Date: Thu, 27 Jan 2011 22:58:02 -0800
Message-ID: <1296197882.2662.0.camel@jtkirshe-MOBL1>
References: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296195535-2990-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110127.223339.226789576.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7163869196662133175=="
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
        "bphilips@novell.com" <bphilips@novell.com>,
        "gospo@redhat.com" <gospo@redhat.com>,
        "stable@kernel.org" <stable@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <20110127.223339.226789576.davem@davemloft.net>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org


--===============7163869196662133175==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2Ypv1ycYuGRnekrXKcUq"


--=-2Ypv1ycYuGRnekrXKcUq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-01-27 at 22:33 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 27 Jan 2011 22:18:51 -0800
>=20
> > diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
> > index 44a1cf0..1495b74 100644
> > --- a/drivers/net/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ixgbe/ixgbe_main.c
> > @@ -3176,9 +3176,16 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe=
_adapter *adapter)
> >  	u32 mhadd, hlreg0;
> > =20
> >  	/* Decide whether to use packet split mode or not */
> > +	/* On by default */
> > +	 adapter->flags |=3D IXGBE_FLAG_RX_PS_ENABLED;
> > +
>=20
> Please fix this indentation, it's a TAB then a SPACE character.

Grrr, sorry I did not catch it.  Fixing it up now.

--=-2Ypv1ycYuGRnekrXKcUq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNQmjwAAoJECTsCADr/EWU+rEH/RDJ+8R5X7J+LmYnrL4f8hoV
DeQHDvAbJU7nUiywpeWm1cTG3QPPPJf1qRA2pwuLBMdytd71t1jIzv/JNDoZdH+q
LziAHc67/QCtgzoBk/e/FT4bOu2odyZZ5SEi7e+HviYUW1/p70Fhc1nI1jPKNnTL
Ib05NymH4b2QeaGLUDXueP0IiF7DULGTwIieKnzNQYVHMU1oU08XEvumD6roz5a9
gY8MmPfIpmBk2qSUbp2LA9H2LnNLmDtIeN6yudpQo+ui00fO3pzO+h5l+QWvbvez
sdc8EfxroTgZ7lLZ+4XyErBNwUAGlKAtj0mHOFASRFt+vrJRChS5EmTn8LK/a/E=
=JV4w
-----END PGP SIGNATURE-----

--=-2Ypv1ycYuGRnekrXKcUq--


--===============7163869196662133175==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable

--===============7163869196662133175==--

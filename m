From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [net 2/8] igb: fix vf lookup
Date: Thu, 09 Feb 2012 01:10:09 -0800
Message-ID: <1328778609.6576.6.camel@jtkirshe-mobl>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <C5551D9AAB213A418B7FD5E4A6F30A0702F86242@ORSMSX106.amr.corp.intel.com>
	 <1328744980.6909.8.camel@joe2Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-J221jg+dLwnBodYbbt45"
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10743 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911Ab2BIJKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:10:10 -0500
In-Reply-To: <1328744980.6909.8.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-J221jg+dLwnBodYbbt45
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-02-08 at 15:49 -0800, Joe Perches wrote:
> On Wed, 2012-02-08 at 23:42 +0000, Rose, Gregory V wrote:
> > > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> []
> > > @@ -5012,7 +5012,8 @@ static int igb_find_enabled_vfs(struct igb_adap=
ter
> > > *adapter)
> > >  	vf_devfn =3D pdev->devfn + 0x80;
> > >  	pvfdev =3D pci_get_device(hw->vendor_id, device_id, NULL);
> > >  	while (pvfdev) {
> > > -		if (pvfdev->devfn =3D=3D vf_devfn)
> > > +		if (pvfdev->devfn =3D=3D vf_devfn &&
> > > +		    (pvfdev->bus->number >=3D pdev->bus->number))
> > >  			vfs_found++;
> []
> > I'll fix this one too.  You start leaning on checkpatch and you get laz=
y I guess.
>=20
> I suppose an indentation rule could be created when
> arguments on multiple lines don't align at the open
> parenthesis, but I'm not going to rewrite emacs
> indentation rules.
>=20
> Presumably it should only be used with --strict.
>=20
> Anyone think multiple line tests with inequivalent uses
> of parentheses like this one should be noted as well?
>=20

I tried to create this very fix last year, but I must admit my
checkpatch.pl foo was not that strong... :)

While it would be a good enhancement to checkpatch.pl, I do not see it
as a "critical" fix.

--=-J221jg+dLwnBodYbbt45
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPM41xAAoJEOVv75VaS+3Oq60P/jvnuJi8Mqq142W+K2kBdJst
WbzeF/zPCmq0DCtFk1yH+Qba+7a+7zaTm2xv0HU7VOhBJtCrNq6E5pjFdO8fyZhx
WCZYs4B8SaoBGxWaEOyUDb8H+afE9Uih7AuSBrXEx2jZvGBDW7Mm/pjT3c5qXKFr
bIDjk899DyuXKHIJ5xtmnRHIsw+P1GVtZnwuJCfeoEm1CdAQGzEhleSTMtlaLyF8
dk0vodlt2z9mw72Xr84gyXwZkskvXMUfai+3yQxCtmmhg+1gOzAXwwZyHq2A1D/Q
3zHS2YphmC5gZLjGHVnX+mqIFY09uU4OzGkjvIFoE54ixkylreNg5yQQOBM6A1sh
OXs5peu9zpGEU/XDdFIL5hWjxaOjBZaiy1cvlFMFiPanmrNKQ5/0k7SkhMElEHyO
Aj7W25H3hfn3ZmEcKmtOi0bxSYl98100Lq8Opw/HlIGi+3fho4R0MRdXarjvOazE
DHr6kLQg46hAvqY3C43yAp+lZXy74aL8IiNXJnR7VLdhlBz9qrd3rnSl9dkVe2Yt
XKUW1mnZNGWqsM8kVf8LAMP1ImE4HuqdIjkOAaItq3x3ibQZle+Ws0gxpRXBgLRD
mCrJjJ+E7Pc4cjteVhbeadx2rzr/aGBctQuW3aSgCU9TL4Ckl7gYTwxMh+2ew6/c
rhQN6Tyym3Z1Qw044h6C
=oMKF
-----END PGP SIGNATURE-----

--=-J221jg+dLwnBodYbbt45--

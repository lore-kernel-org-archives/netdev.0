From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sun, 20 Apr 2008 09:21:03 +0400
Message-ID: <200804200921.09072.arvidjaar@mail.ru>
References: <1208171478.31695.58.camel@pmac.infradead.org> <1208176322.31695.73.camel@pmac.infradead.org> <20080419.183341.46125500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1786829.yDRibfeeRA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com
To: linux-hotplug@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20080419.183341.46125500.davem@davemloft.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1786829.yDRibfeeRA
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 20 April 2008, David Miller wrote:
> We're trying to provide uniqueness amongst all devices in the system
> that are using the same MAC address.
>=20
> On a Sparc system, for example, ethernet chips driven by several
> different drivers can end up with the same MAC address, as the
> system IDPROM specified ethernet MAC is what will be used by
> default.
>=20

On Sparc system we also have global device tree which provides unique
and persistent reference to every device. Solaris has no problems with
having same MAC for all interfaces.

> So we need some global scheme.  And this dev_id value would need to be
> persistent.  As best as I can tell, such things aren't available.

What is exactly wrong with using device topology path? This should exist
on any system, it is unique and it is persistent.

> Sure we could do something silly like use the device I/O physical
> address, but that would defeat the whole purpose of making device
> identification agnostic to I/O bus geography.  I could move the
> card to a different slot and it would have a different dev_id.
>=20

Sure; a card in different slot *is* a different device. And when broken
card is replaced in the same slot for all practical purposes it *is* the
same device even if MAC has changed.

Nobody makes cable labels like "card with MAC xxx"; every cable label has
something like "shelf 2; PCI slot 3; port 1".

--nextPart1786829.yDRibfeeRA
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkgK0sEACgkQR6LMutpd94xB6wCfRdsiPq27Tah12z5YKw9vmjvE
V5cAmgJrRQzJPXLiQV15yIJe37WJSBA9
=GDW9
-----END PGP SIGNATURE-----

--nextPart1786829.yDRibfeeRA--

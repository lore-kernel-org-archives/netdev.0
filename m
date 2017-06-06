From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH] net: mvpp2: do not bypass the mvpp22_port_mii_set
 function
Date: Tue, 6 Jun 2017 15:51:48 +0200
Message-ID: <20170606135148.GA22618@kwain.lan>
References: <20170606133615.20747-1-antoine.tenart@free-electrons.com>
 <20170606154535.3e87bafb@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="0F1p//8PRICkK4MW"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, netdev@vger.kernel.org,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38883 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdFFNvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 09:51:51 -0400
Content-Disposition: inline
In-Reply-To: <20170606154535.3e87bafb@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Thomas,

On Tue, Jun 06, 2017 at 03:45:35PM +0200, Thomas Petazzoni wrote:
> On Tue,  6 Jun 2017 15:36:15 +0200, Antoine Tenart wrote:
> > The mvpp22_port_mii_set() function was added by 2697582144dd, but the
> > function directly returns without doing anything. This return was used
> > when debugging and wasn't removed before sending the patch. Fix this.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
>=20
> Please add:
>=20
> Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")
>=20
> with this:
>=20
> Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

OK, will do.

> I am wondering if we shouldn't Cc: stable as well. I don't think we
> have seen issues on our side because U-Boot does the necessary
> initialization, but people using other bootloaders might have issues.

Yes, that might be safer to cc stable. I'll do this as well.

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--0F1p//8PRICkK4MW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZNrN0AAoJEFxNi8it27zYNCAP+gKwUFQWKRbRXHV0wqjcRCP3
TF9SRFZNVjg96yAmSxfFoYWVKOwVshfHNXRO7Pv0ApH84c8EQ+ygScfZJnkxktlk
OyY/JcZ2ZEZvugYbuFAvM9WkQam1O1e2U+mtMWEtqg0RpxZ1hOgyRxCg/IG0rK5G
WGtWkHus7cr3i9nOoIUR2BIo+b6WY9al8TGUeyaKFG9SKqda83tiwCQTOJydQzPk
bAEI5OItPYlVpjN+xLKez1ac3lMFoBvwFdpYUuL00JnTyzR7WxmMknIbDoz0FBbW
UZaTe7eVtW7adGGNa2JG0jSYCqAvpXgoVzVi9xEpmE7v2zb9rhf9uLxjAtkVCy4u
T4eOOlTGWgpY3UvhTPjYnxecVwb4k+jg3jRR1jgEX9gxkc4nklP4JiJ0UE7h2Wcu
9EQI5DO+VQSGOtrvWEGT0M8hLYdsXw3fl2G4rYsxq6B2ZUQmzpej+foCgftxWhoi
jR4kpCBWwKwegZR3iESX9w9RmdcgfIXghg96/40YM2QsYpyYBtQVqi6266lTES2U
AUTDcNHNKRGi+w9ybKVvfTbYk7jVkbcrdKVSEsnsUxQjoE3OTWe7c8nH6YVeRWs6
kglQ/h0yNs86/PEQgaUy/0kSZrOttNHQTcAaUdFtJg+47iHRPinnBFzWCgdPcZYJ
8V04NDs4rf+HB5Mj02WT
=5daV
-----END PGP SIGNATURE-----

--0F1p//8PRICkK4MW--

From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Wed, 29 May 2013 21:44:38 +0200
Message-ID: <20130529194438.GY3333@ritirata.org>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
 <20130528.233647.1209227470109213894.davem@davemloft.net>
 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="5KENZRfAmuo1v8rU"
Cc: David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, horms@verge.net.au
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54560 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759607Ab3E2Tqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 15:46:32 -0400
Content-Disposition: inline
In-Reply-To: <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5KENZRfAmuo1v8rU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 29, 2013 at 08:34:33PM +0100, Ben Hutchings wrote:
> On Tue, 2013-05-28 at 23:36 -0700, David Miller wrote:
> > From: Cong Wang <amwang@redhat.com>
> > Date: Wed, 29 May 2013 14:09:00 +0800
> >=20
> > > commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> > > fields of struct skbuff) converts skb->*_header to u16,
> > > therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
> > > 2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.
> > >=20
> > >=20
> > > Cc: David S. Miller <davem@davemloft.net>
> > > Cc: Simon Horman <horms@verge.net.au>
> > > Signed-off-by: Cong Wang <amwang@redhat.com>
> >=20
> > I want to use something that will either break the build or
> > automatically work if the type changes again.
> >=20
> > So something like "X =3D (typeof(X)) ~0U;".
>=20
> I think you mean ~(typeof(X))0.

Am I wrong or you should cast the value once again, like this:

((typeof(X))~(typeof(X))0)

because the ~ operator will implicitly cast the argument to int (if I remem=
ber
correctly).


Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--5KENZRfAmuo1v8rU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRplqmAAoJEADl0hg6qKeOa8cP/3VnA7j1UKW96kWQbo+7Jf8+
xzY3m2gpG00YPjYQZWw9thaKp9X+qexgjD2qW2i5L5UFPQLhiv5GIfX1oOx6VeX0
5ZajZv//mt5BHfBs0Pt6mZaULprB2delnkyHMDZEri1mjemTiP/bSbhml7LdDG3b
5Chd5ey8kx5lZLYc1o4Y/UPNRqPvgy4qJgE9jk7hz4Qbt1jtkxm6Dr1+wx9HvD8g
OqCj+eBUqKcPy9v7rtx+JRZhUSo+fAJ4oS+yty55ZLb8KPveIcLf6r0END5Rh38i
gplZX1CKypMj2ciJa1AjCyhmcDly5USUruAZerH0ZT42lTHV76laqcOlnvuZOH6w
Bl8HCRM32aJ9rT+EO4edaaCszWLJT+jUa836fotXqBpzTpoPIILYVLr45QZUsxl5
ah5mYDzVevTNErOqmMDvr/xwubFYDVrY2v/93pXHANH1PqBVYX8et06wPZld6igu
smwqrfEZ+My9m9p5DZWwA2wJEsf2ebl1pIu6AZVzs8Zi/Qz+gCU/zAb6KXbZ+jyQ
P05X+DcK/DByLSutqPmp/Ac+L0EoEvnj/vqU/lvze61608WunGqOVFApCb+yuBHQ
CFKGs8djSAvSOjlaxvRf3xJJMsVXqJyEkZdkVxHTq46QtT5W+VE6UOSp5VLAG+HT
bKQgJbfXI1rcIWOCs8Bx
=b8EP
-----END PGP SIGNATURE-----

--5KENZRfAmuo1v8rU--

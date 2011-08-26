From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] e1000: save skb counts in TX to avoid
 cache misses
Date: Thu, 25 Aug 2011 20:52:39 -0700
Message-ID: <1314330760.2097.39.camel@jtkirshe-mobl>
References: <20110826003923.4083.24862.email-sent-by-dnelson@localhost6.localdomain6>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-KIw9PJRNwYOGE2z7jpUZ"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27563 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059Ab1HZDwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 23:52:40 -0400
In-Reply-To: <20110826003923.4083.24862.email-sent-by-dnelson@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KIw9PJRNwYOGE2z7jpUZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-25 at 17:39 -0700, Dean Nelson wrote:
> Virtual Machines with emulated e1000 network adapter running on
> Parallels'
> server were seeing kernel panics due to the e1000 driver dereferencing
> an
> unexpected NULL pointer retrieved from buffer_info->skb.
>=20
> The problem has been addressed for the e1000e driver, but not for the
> e1000.
> Since the two drivers share similar code in the affected area, a port
> of the
> following e1000e driver commit solves the issue for the e1000 driver:
>=20
> commit 9ed318d546a29d7a591dbe648fd1a2efe3be1180
> Author: Tom Herbert <therbert@google.com>
> Date:   Wed May 5 14:02:27 2010 +0000
>=20
>     e1000e: save skb counts in TX to avoid cache misses
>=20
>     In e1000_tx_map, precompute number of segements and bytecounts
> which
>     are derived from fields in skb; these are stored in buffer_info.
> When
>     cleaning tx in e1000_clean_tx_irq use the values in the associated
>     buffer_info for statistics counting, this eliminates cache misses
>     on skb fields.
>=20
>=20
> Signed-off-by: Dean Nelson <dnelson@redhat.com>=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Looks fine.

--=-KIw9PJRNwYOGE2z7jpUZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOVxiHAAoJECTsCADr/EWUgRgH/3ZFTc0XQ+6zc9VPT/S2TAWX
/M0KyWMv5QiOj1+Ror80nBIJT6DpAiNqMuXClQb6c2aTE/CRswA/ajw27eNyoDbN
dX+gwfUsaIYVu/2KVoatKP7P5wqcJCDBDvjC9togf8CAGYD9v2TABQLUd/KR9mds
U45QVIIp/MSN6+jGhLSf+3Q1FggjE78xhpc3UiTR1kxjbpcCdIbdHFO+13EbioeE
8yHq/pTYTBkwXu1FsWKEzUeo/2482wqaP0JAQmoBcLOoIxI9htIHdiwPTMy9i1G4
iJXc4MGA0Kki1cUYEFcNzNfk/jCXGK4rJdOQfMy0SqczGnwj1qjVODea01IJTnA=
=EQgU
-----END PGP SIGNATURE-----

--=-KIw9PJRNwYOGE2z7jpUZ--

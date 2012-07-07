From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [PATCH net-next 3/5] net: Fix non-kernel-doc comments with
 kernel-doc start marker
Date: Sat, 7 Jul 2012 09:04:42 +0200
Message-ID: <20120707070442.GB27557@ritirata.org>
References: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
 <1341614742.2923.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:21716 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab2GGHEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 03:04:33 -0400
Content-Disposition: inline
In-Reply-To: <1341614742.2923.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 06, 2012 at 11:45:42PM +0100, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  net/ceph/pagelist.c |    6 +++---
>  net/dcb/dcbnl.c     |    2 +-
>  net/ipv4/tcp.c      |    2 +-
>  net/tipc/socket.c   |    2 +-
>  4 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
> index 13cb409..693852f 100644
> --- a/net/ceph/pagelist.c
> +++ b/net/ceph/pagelist.c
> @@ -95,7 +95,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, siz=
e_t space)
>  }
>  EXPORT_SYMBOL(ceph_pagelist_reserve);
> =20
> -/**
> +/*
>   * Free any pages that have been preallocated.
>   */


Am I wrong or this kind of comment should be:

/* Free any pages that have been preallocated. */


> -/**
> +/*
>   * Truncate a pagelist to the given point. Move extra pages to reserve.
>   * This won't sleep.
>   * Returns: 0 on success,

And this also should start like:

/* Truncate a pagelist to the given point. Move extra pages to reserve.
 * .....

?

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAk/334oACgkQpGgxIkP9cwflswCeMzTvjZgY41Mbah2tFT8vD+aH
bAMAn2iB9655NWvvGZ96L0VKn6zBrFQK
=dd8V
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--

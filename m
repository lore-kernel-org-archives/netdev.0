From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v2] [02/10] pasemi_mac: Stop using the pci config space
 accessors for register read/writes
Date: Sat, 25 Aug 2007 11:19:47 +1000
Message-ID: <20070825111947.03326126.sfr@canb.auug.org.au>
References: <20070817205413.548020000@lixom.net>
	<20070822141248.GC16830@lixom.net>
	<20070823181310.GB31882@lixom.net>
	<20070824140531.ff7d66bf.sfr@canb.auug.org.au>
	<20070824181104.GA17171@lixom.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__25_Aug_2007_11_19_47_+1000_emKxv+4N=YrETn77"
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:53803 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757049AbXHYBT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 21:19:59 -0400
In-Reply-To: <20070824181104.GA17171@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sat__25_Aug_2007_11_19_47_+1000_emKxv+4N=YrETn77
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 24 Aug 2007 13:11:04 -0500 Olof Johansson <olof@lixom.net> wrote:
>
> On Fri, Aug 24, 2007 at 02:05:31PM +1000, Stephen Rothwell wrote:
> >=20
> > It is not documented as such (as far as I can see), but pci_dev_put is
> > safe to call with NULL. And there are other places in the kernel that
> > explicitly use that fact.
>=20
> Some places check, others do not. I'll leave it be for now but might take
> care of it during some future cleanup. Thanks for point it out though.

No worries.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__25_Aug_2007_11_19_47_+1000_emKxv+4N=YrETn77
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGz4O9TgG2atn1QN8RAn4AAJ4p1By/HopIDnyDA1qnzRDVNUkQPgCgjVcv
H7WpqCrskV0gFHn6wfwl3P0=
=tyQL
-----END PGP SIGNATURE-----

--Signature=_Sat__25_Aug_2007_11_19_47_+1000_emKxv+4N=YrETn77--

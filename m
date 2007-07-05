From: =?iso-8859-15?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Thu, 5 Jul 2007 19:50:59 +0300
Message-ID: <200707051951.03619@auguste.remlab.net>
References: <200707051618.l65GIh0J030375@quickie.katalix.com> <468D200E.1060200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1349722.f7n9S0VL3f";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:4673 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757040AbXGEQvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 12:51:08 -0400
In-Reply-To: <468D200E.1060200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1349722.f7n9S0VL3f
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le jeudi 5 juillet 2007, vous avez =E9crit :
> James Chapman wrote:
> > This cleanup fell out after adding L2TP support where a new
> > encap_rcv funcptr was added to struct udp_sock. Have XFRM use the
> > new encap_rcv funcptr, which allows us to move the XFRM encap code
> > from udp.c into xfrm4_input.c.
> >
> > Make xfrm4_rcv_encap() static since it is no longer called
> > externally.
> >
> > Signed-off-by: James Chapman <jchapman@katalix.com>
> >
> > ---
> > Tested with L2TP and L2TP/IPsec.
> >
> > Update after comments from Patrick. Fix encapsulated transport mode
> > case and remove stupid file history comment change.
>
> Looks good, thanks.

By the way, couldn't encap_type be remove altogether (using two slightly=20
different callbacks for ESP) from udp_sock?

=2D-=20
R=E9mi Denis-Courmont

--nextPart1349722.f7n9S0VL3f
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iEYEABECAAYFAkaNIXcACgkQw+xtvt1tEr1aWgCfRVB7jnb19IZCvfTLWj4mwHQ3
bWQAoIXqX+ogINR9oySKcnNzRBQow/2t
=GiSo
-----END PGP SIGNATURE-----

--nextPart1349722.f7n9S0VL3f--

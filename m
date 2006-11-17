From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: d80211: RFC: divide by zero when hw->maxssi not set
Date: Fri, 17 Nov 2006 18:59:47 -0500
Message-ID: <200611171859.51941.flamingice@sourmilk.net>
References: <20061117235109.GA11885@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5881385.ejcelDNgF4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:41869 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1756052AbWKRABX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 19:01:23 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061117235109.GA11885@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5881385.ejcelDNgF4
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 17 November 2006 18:51, David Kimdon wrote:
> - reject registration of devices which do not set maxssi
> - do not attempt to report link quality for drivers which do not
>   set maxssi
> - other ideas?
>
I've noticed that too. p54 didn't get a driver update when maxssi was added=
=2E I=20
don't mind adding a dummy maxssi just to make sure we don't divide by zero.=
=20
In fact, I'm going to come up with a patch for p54 to do that soon.

=2DMichael Wu

--nextPart5881385.ejcelDNgF4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFXkz3T3Oqt9AH4aERAizPAJ9ItKOr/DUmX1hxDhzhKrYmXMICKQCcCG/a
3LeiKQ7AL3nXNKtstBNGxv0=
=b4i2
-----END PGP SIGNATURE-----

--nextPart5881385.ejcelDNgF4--

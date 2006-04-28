From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Fri, 28 Apr 2006 08:17:28 -0300
Message-ID: <20060428111727.GC5196@rama>
References: <443EF3E9.7050303@lwfinger.net> <20060415174734.GA10595@infradead.org> <4443D694.8090809@hp.com> <44501647.8070308@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4ZLFUWh1odzi/v6L"
Cc: Rick Jones <rick.jones2@hp.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:62854 "EHLO
	ganesha.gnumonks.org") by vger.kernel.org with ESMTP
	id S1751376AbWD1WmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:42:08 -0400
Received: from uucp by ganesha.gnumonks.org with local-bsmtp (Exim 4.50)
	id 1FZbf5-0001CL-4h
	for netdev@vger.kernel.org; Sat, 29 Apr 2006 00:42:07 +0200
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <44501647.8070308@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4ZLFUWh1odzi/v6L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 26, 2006 at 07:54:31PM -0500, Larry Finger wrote:
> I am leaning toward putting the geographical information into a
> userland daemon.=20

I like that idea very much.  This is all control metadate that doesn't
really need to be in the kernel.

> That way we won't have to patch the kernel every time a country
> modifies its regulations.=20

that's another advantage.

> In addition, the kernel will be smaller. The downside is that the
> daemon will have to be updated and supplied in some convenient form,
> perhaps as part of a wireless tools package.

Ideally the daemon would get the table of country restrictions from a
policy file (some human-readable ascii?).  That file can then be
downloaded by a cronjob to keep it updated, if desired.  A bit like the
PCI/USB device id databases...

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--4ZLFUWh1odzi/v6L
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEUfnHXaXGVTD0i/8RAjihAJ4j9TecscXasCfwHQHIRMECG75h0ACeIdNm
JR2ULURmRSzR08QXuvEQIIo=
=KUNl
-----END PGP SIGNATURE-----

--4ZLFUWh1odzi/v6L--

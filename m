From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 2/4] batman-adv: fix kernel crash due to missing NULL
 checks
Date: Tue, 11 Aug 2015 18:42:45 +0200
Message-ID: <55CA2605.1070201__5203.84353953904$1439311434$gmane$org@meshcoding.com>
References: <1438779107-12665-1-git-send-email-antonio@meshcoding.com>
 <1438779107-12665-3-git-send-email-antonio@meshcoding.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB737B7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="07cHLHPAhjOK66dSWoq1BMb18TfC1RMaG"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"b.a.t.m.a.n@lists.open-mesh.org" <b.a.t.m.a.n@lists.open-mesh.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:25046 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755329AbbHKQnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 12:43:42 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB737B7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--07cHLHPAhjOK66dSWoq1BMb18TfC1RMaG
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/08/15 15:15, David Laight wrote:
> So is this test just hiding anoter bug somewhere??

Hi David and thanks for your feedback.

The point is that we got several bug reports of kernel crashes due to
NULL pointer deferences in these lines and fter having debugged this
problem for quite a while we preferred to move on and propose this patch.=


Still, I am personally debugging this part of the code to understand if
we really have something wrong or if this NULL pointer is something we
should expect (and therefore check).

For the time being we think this patch is better than having horrible
kernel crashes, but I hope to come to a definitive conclusion soon.

Cheers,


--=20
Antonio Quartulli


--07cHLHPAhjOK66dSWoq1BMb18TfC1RMaG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVyiYJAAoJEOb/4TMchkvfxR4P/0/RZbf9gwyMmM3gPzCAcXEL
jFbg+R/lf0pORZO9OPrSvwS2wJKOKxnJZMc8oeCq3hx7h9BvPwM5dl2pefNFO8ZS
9Tf7HGVgQ5xH6JCfFwS0ILZxnnqTHOnSvyyzb4l+SXZqQSvbvLycmkBckSG1JnG2
SKMEav0APSDWLvo2VhpLRzWMHmzalZCJAXsSB/S3mo+Oun8QcMMgIRpWqUKizekS
wkyGYjq6lGz6cW1/vQKDS9hCudDiRSlyataIQ1Bg4zR03ob1h1GYYcR6PWKDe/v/
1ZV7SimOX10VJdtihq9arLSfZV7RqybwqsnCLahskIds2RRrB9RyM+i1bmT7x1IC
F6atCb7ymXu4ciGU7J93QpC1m3GpZEj26rQZIbePloTQIphfgNhCP5bhTvKe9sQX
mnSKi0Tou0MKkDcQeNmXxQQwRfT52JadKIzBJMXuzDOZLrTh+g6g3fDBEbMAEYGX
Te0NKn6jlVUyC6oTC/Labq2jlv5AjurMP5JhEogSP3Y7apSilrplQIVHjgXYQKiy
PFCkZjNcXHrGL4pLf9lXJc8qq0VP6NxibX565cZpo7PFBAcQdWTeQ7mNYXGvKfFy
LdVkgT2oafuOU5Sroe81CLXK/kp0X3TLFkigYo//ihPrd9Ah5h6WmlnsMz8TJ3+a
CMMDDYF9cWEBUALLmXip
=jJc+
-----END PGP SIGNATURE-----

--07cHLHPAhjOK66dSWoq1BMb18TfC1RMaG--

From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH 0/2] l2tp: fix ancilliary data handling in ip6 recv
Date: Wed, 30 Jan 2013 09:50:56 +0000
Message-ID: <20130130095056.GB2519@raven>
References: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
 <20130129.141239.2228875361542418234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MW5yreqqjyrRcusr"
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40076 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754396Ab3A3Ju7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 04:50:59 -0500
Content-Disposition: inline
In-Reply-To: <20130129.141239.2228875361542418234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MW5yreqqjyrRcusr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 29, 2013 at 02:12:39PM -0500, David Miller wrote:
> Please rewrite this patch set, starting with a rename of both
> datagram_recv_ctl() and datagram_send_ctl() such that you can
> tell, by name, that they are ipv6 specific functions.
>=20
> Please make sure to grep the entire tree and fix up all references,
> they are references to the names in comments too.

Sure, will do.  Thanks, David.

Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--MW5yreqqjyrRcusr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRCO0AAAoJEJSMBmUKuovQaDgH/jkfrk2OtW8vSWlFnb/6ITqQ
iid4mHKFhQE5lBX/2OKO7IFD3nm8d98bgoQRO+lQ1wI3AUHI13xLqYCzvxBFYvTP
q5tYooNeZrZuGWmancYLfrkREwdlUAD6p3NrZe3iU/ulzji2YPXtFoLTFakvOq4X
sKrRm76nwiXdRr/vZfRV0b2D7yEn3DDL6vvHDIAnhVJ8L41BCOnzFBcZeP/CXPye
kbT3163/njss+I85bFR6q8ZsvZXQDQe+l6ZMLnSpBrv2aUgiSs7yJyxrTTaM72fs
8bSK/WFim3Sy0F1fc0cp74RqsMMKJbFyMqYM+Bu8WB59IwKj5IVdHq0a32iAINw=
=AyMC
-----END PGP SIGNATURE-----

--MW5yreqqjyrRcusr--

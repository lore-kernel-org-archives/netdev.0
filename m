From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH 0/4] l2tp: fix namespace support in l2tp_core
Date: Tue, 5 Feb 2013 09:27:09 +0000
Message-ID: <20130205092709.GA2465@raven>
References: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
 <20130204.132107.47370979625013842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42596 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab3BEJ1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 04:27:16 -0500
Content-Disposition: inline
In-Reply-To: <20130204.132107.47370979625013842.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 04, 2013 at 01:21:07PM -0500, David Miller wrote:
>=20
> These patches don't apply cleanly to net-next, please respin.

Hmm.  I think the problem is that this patchset builds on the bug-fix
work of this previous submission:

  * l2tp: prevent l2tp_tunnel_delete racing with userspace close

The bug fix patch went to the net tree, not net-next, hence the
problem.  I should have made the dependency between the two patches
more explicit -- apologies for not having done so!

What's the right thing for me to do in a situation like this?  Should
I wait and resubmit when net-next and net are next synchronised?

Thanks,
Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRENBtAAoJEJSMBmUKuovQoXoH/2LOPHytHtYCXswX68hj/UxG
rAdpd/Fvk5rCgpgII7ff7RJry9UDC0HQEAG7tu11Fs9vf+kFLNqCku4dzrg0Rlt1
UxmukbsuHY+yCXIrw5Zxo5BLF6kkP5llYsXqiDkSfrSWom1IHYnT4v4ZK34y+3YS
6HYABbFbTg9e9K1bt7Enj2eYFi04w/63vdXpWeEgn7ErYHx7+D8e+KMHSrB8DwdU
kkeWBgAPJNiJhCkvnDeN+1JywpjXG5sxwjjOTLlOkgwOdCGi2DSoSmabrbZ8UbW+
rZHqLThpqbvnQ0VE6bSSTGDy9HEJex4iotY7kH2DewbTDiglnzLjkNccomiCsDU=
=KISJ
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--

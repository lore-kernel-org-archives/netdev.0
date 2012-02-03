From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net 4/8] ixgbe: fix namespace issues when FCoE is not enabled
Date: Thu, 02 Feb 2012 21:46:54 -0800
Message-ID: <1328248014.2581.33.camel@jtkirshe-mobl>
References: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328185221-8591-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120202.142005.1066192595268413170.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NH5j/xHEoxsoQuneG/QM"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16403 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935Ab2BCFqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 00:46:55 -0500
In-Reply-To: <20120202.142005.1066192595268413170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NH5j/xHEoxsoQuneG/QM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-02 at 14:20 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu,  2 Feb 2012 04:20:17 -0800
>=20
> > Several functions are made external but are not used externally when
> > FCoE/DCB is not enabled.
> >=20
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>=20
> Do not crap up the *.c files with ifdefs like this.
>=20
> Better to export these operations via an ops structure of
> some kind, rather than doing stuff like this.
>=20
> I'm not applying this series if it contains stuff like
> this.

I apologize Dave, that was my mistake.  I will drop this patch from the
series and find a better way to resolve the namespace errors.

--=-NH5j/xHEoxsoQuneG/QM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPK3TOAAoJEOVv75VaS+3Ov70P/0ZEgesyta8wwnGc25WZDwNN
Wyvpwnwy3Ui+zPw0JgyelGulSWlebZnuGctHd86KLcJCKos39UAOpAPhSafVhBqP
jzXE5dwNZQIZfqTdK8yw746B/lhGBPZdbBuqxsEomQMrono6HbKXuSAeuYE6mSu7
VyuzH54r4mQzhT4rGLZPMMIxFfJtLBtTyRomFjuk1By+N2wNhlAUBbEqavcta1tp
uiO3YTGbdgfBnqi525xhNUKZkyvTy7laZd31GFMINRqOFq7U5aFF/4J9SnoGSO2c
b/HQmgyXoEvx1czIkq25Z+chac8vVrRtLdarPHy/MWo0wGUQ2mtR0afimzhrdSkX
mptGKp/FwMzoc7WlauzxWmdcIKGPx5CRUlHwLewB15D5gQMydosHuu9mntld2nPr
BSXQ6eRIZJb0AOvRjkMAYgS2QfrYX+bqZdFLFIm18UzhfrO/KhjUWhSt3PB1fFIP
WxFXarU/2ckwYTLfjXzycHjtvQGRdFS2SNLvzMMRsyoXanaW1YayXaNJZ0bzFVQX
iWFSXmxtbtrX8ETnEO98DD17w87SuNNNefX5AolVtQfP/aFc0XHpftg1a8LSzCo1
O4ZHXJKOeJCW5LPFwwXwdJngP+4RwakKW8EtWwxQLWORAx0XIPH5Hl3ZTT2uxIRS
Mj3uQ07Oy0Z4lxQ/9dwN
=ErlR
-----END PGP SIGNATURE-----

--=-NH5j/xHEoxsoQuneG/QM--

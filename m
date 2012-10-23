From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 08/12] ixgbe: using is_zero_ether_addr() to simplify
 the code
Date: Mon, 22 Oct 2012 22:17:47 -0700
Message-ID: <1350969467.2135.11.camel@jtkirshe-mobl>
References: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350966385-19020-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350967518.7502.32.camel@joe-AO722>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5cl8vLg4MbslqCArz7ND"
Cc: davem@davemloft.net, Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32756 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949Ab2JWFRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 01:17:55 -0400
In-Reply-To: <1350967518.7502.32.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5cl8vLg4MbslqCArz7ND
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-10-22 at 21:45 -0700, Joe Perches wrote:
> On Mon, 2012-10-22 at 21:26 -0700, Jeff Kirsher wrote:
> > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > Using is_zero_ether_addr() to simplify the code.
> []
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/=
net/ethernet/intel/ixgbe/ixgbe_common.c
> []
> > @@ -1778,8 +1778,7 @@ s32 ixgbe_validate_mac_addr(u8 *mac_addr)
> []
> > -	else if (mac_addr[0] =3D=3D 0 && mac_addr[1] =3D=3D 0 && mac_addr[2] =
=3D=3D 0 &&
> > -	         mac_addr[3] =3D=3D 0 && mac_addr[4] =3D=3D 0 && mac_addr[5] =
=3D=3D 0)
> > +	else if (is_zero_ether_addr(mac_addr))
>=20
> This means the more comprehensive simplifying patch
> I submitted doesn't apply.  Easy to fix up though.
>=20

Yeah, I have taken care of fix up to your patch in my queue.  Want me to
send you the fixed up patch so that you can confirm my fixes?

--=-5cl8vLg4MbslqCArz7ND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQhih7AAoJEOVv75VaS+3OSIkP+gLJKTOo125sTDu0linGMN61
MfozRDQp6705C4SW3mkwDjiDCt11O4b7cKOiCmSNoKvX2lOBot5+juvjuyRQvSbK
OYQth8NKrpLs3sPuEEK2DEgE4MRHzeoeUYLUzaK8CNdefXEA+B+NWgqH7oHXqitD
MJ65tpltsuYtF2KskFnbnTWWLbV1+ifoSgkNgTNkn12gTr4n0tTvu7o7ROcs/+Tf
wfDuiu1hv38L7eATVNHCCtblNTcfUwScUWBSd+Epnlz8Ch7e1h0GZlg1ofLgUatM
7EESksG4jmrB1oqpHQxYbka+mkJpZhXVRmK+/5DN9T8Wte62DDHJCDDxYuOg51X1
/EfxItz5cWOg1uPZwTzgkxlNW1tgOESZjiIR8QXbeiViJSVJLvWfV3jc7SnwKFcu
Y17UGuyGTrMrKwR6C8sgk/J/npMLZy4+Z2ETcpQsIx1cM/msg9J1NJrtWjW2RMar
OFi4rp3am5urJP01A/6CCZwv0Rf4A71CYxXWWE2HE1vMCQaHCrJeEJDjIxlPvj5y
S3lPXNKh6jsJMU4MVyaB0GTux3+a7OJWGho4xDrFVy97HtNlozI1ixr/tqLq7Ez9
D2XzzR6A/8+0UXCchxddlK0oJjrw4RkbVZAMkz55EJdcWIk4ypA8Oriq96OgKyDI
GPQ9fSrQL/PbOcAbidgB
=J+Y8
-----END PGP SIGNATURE-----

--=-5cl8vLg4MbslqCArz7ND--

From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: next tree for October 27:  znet build failure
Date: Wed, 28 Oct 2009 01:37:21 +1100
Message-ID: <20091028013721.049c0146.sfr@canb.auug.org.au>
References: <20091027190850.9694fb39.sfr@canb.auug.org.au>
	<4AE6BEC7.2030703@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__28_Oct_2009_01_37_21_+1100_3o3/8wKb9Zsi6da2"
Cc: linux-next@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Greg KH <greg@kroah.com>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:52983 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525AbZJ0OhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 10:37:24 -0400
In-Reply-To: <4AE6BEC7.2030703@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__28_Oct_2009_01_37_21_+1100_3o3/8wKb9Zsi6da2
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Just adding John and Greg to the cc list as this is caused by patches in
the staging tree.

On Tue, 27 Oct 2009 15:05:03 +0530 Sachin Sant <sachinp@in.ibm.com> wrote:
>
> Fails to build on x86_32 with lots of errors related to znet
>=20
> drivers/net/znet.c:107:29: error: wireless/i82593.h: No such file or dire=
ctory
> drivers/net/znet.c:133: error: field 'i593_init' has incomplete type
> drivers/net/znet.c: In function 'znet_set_multicast_list':
> drivers/net/znet.c:235: error: invalid application of 'sizeof' to incompl=
ete type 'struct i82593_conf_block'
> drivers/net/znet.c:247: error: dereferencing pointer to incomplete type
> .....
>=20
> Commit 879e9304... moved wireless/i82593.h to drivers/staging/wavelan/i82=
593.h
>=20
> Thanks
> -Sachin
>=20
>=20
> --=20
>=20
> ---------------------------------
> Sachin Sant
> IBM Linux Technology Center
> India Systems and Technology Labs
> Bangalore, India
> ---------------------------------
>=20


--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__28_Oct_2009_01_37_21_+1100_3o3/8wKb9Zsi6da2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkrnBaEACgkQjjKRsyhoI8wQTACfYAhRQ4FqCL4tWGeQ4hUBMRe5
wfEAnAooPN9lZEE8KJSXk71DpxKF2Ioi
=Waq2
-----END PGP SIGNATURE-----

--Signature=_Wed__28_Oct_2009_01_37_21_+1100_3o3/8wKb9Zsi6da2--

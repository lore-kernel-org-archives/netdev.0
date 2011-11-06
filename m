From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: ixgbe: compilation failed if CONFIG_PCI_IOV isn't set
Date: Sat, 05 Nov 2011 20:18:59 -0700
Message-ID: <1320549540.5386.29.camel@jtkirshe-mobl>
References: <20111106000819.GC12157@vaio>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wsR+NquClQ7dguKXzZwR"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Li, Sibai" <sibai.li@intel.com>
To: Alexander Kolesen <kolesen.a@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33497 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908Ab1KFDTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 23:19:01 -0400
In-Reply-To: <20111106000819.GC12157@vaio>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wsR+NquClQ7dguKXzZwR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-11-05 at 17:08 -0700, Alexander Kolesen wrote:
> Hello.
> I've tried to build vanilla kernel (HEAD: 5c8a0fbb) and got the error:
>=20
>   CC [M]  drivers/net/ethernet/intel/ixgbe/ixgbe_main.o
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_set_i=
nterrupt_capability':
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:4724:3: error: implicit d=
eclaration of function 'ixgbe_disable_sriov'
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_remov=
e':
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7773:3: error: implicit d=
eclaration of function 'ixgbe_check_vf_assignment'
>   make[5]: *** [drivers/net/ethernet/intel/ixgbe/ixgbe_main.o] Error 1
>   make[4]: *** [drivers/net/ethernet/intel/ixgbe] Error 2
>   make[3]: *** [drivers/net/ethernet/intel] Error 2
>   make[2]: *** [drivers/net/ethernet] Error 2
>   make[1]: *** [drivers/net] Error 2
>   make: *** [drivers] Error 2
>=20
> Looks like the commit 9487dc84 breaks it when the CONFIG_PCI_IOV switched=
 off.
>=20

Was with the latest kernel from David Miller's net.gt tree?  I just ask
because I just pushed a patch (a couple of days ago) to resolve
compilation errors when CONFIG_PCI_IOV is not enabled by Greg Rose.

--=-wsR+NquClQ7dguKXzZwR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOtfyjAAoJEOVv75VaS+3OUrcP/itB4/qXFFL8+DLNjXSpT5bT
o90Mv5F2jKmB7pM8q41ZvyIEIgioRLy2sqbGon5dpmu8tljKHdXU6U1Mv/kfDmGM
vGVOBWASkdYTgrX58vdsMcQfy1le1Kvjms36L8gtjskWmm5yo/kTmNRwfIZ7ctKF
rjSQP32ExfyEEAEFP70nun0SKMZbbeJWCM4YrbbgHqD3RIqRvHY6yJ3DMLloWb/O
AQLRnPN2kCipqab62QkMbxWAiqBjVa//wttKP5StAJdSjklIJ+irF320kh/+G9iQ
TyshHGZNAw/kjBRFc6EdrFD9duSu6vFzX0rDC9/mA5BOSePq039k2w6tHwRp4gwk
cGnUERDjhLACJod9XWi5g9WTwYpHs/t3lgvHNd9ai1p4nQyfb9hdsIoJKH79xC0L
edvPymWUZDpS3JvLJa4EuculprfCTWai3uYYPI7BJh+3Ar3gE+VvpZodS/8+4zeS
EdBe6Z4IItezzBhw8PgSTOu7gx6YnWaszYkhZUH14fc7KiYTlIYt9na0Tj7ukwgb
R0wCrJOauWsJfgAeDS+kbTuzu0rQczZN0SP1rF0E4XeGCoOwl6d8HyVTGp9lkRea
3SHtaEb3CUh5IyTGdGsmm9nk69jZ+eRK4LS2wf2LLqIg6ye/Nf4BqS9cBzJE50EP
UEsxmm0IPYrtsymWJGfa
=DKxX
-----END PGP SIGNATURE-----

--=-wsR+NquClQ7dguKXzZwR--

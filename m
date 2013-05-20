From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH 1/4] e1000e: Remove duplicate assignment of default rx/tx
 ring size
Date: Mon, 20 May 2013 02:37:16 -0700
Message-ID: <5199EECC.8040900@gmail.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com> <1369037707-27026-2-git-send-email-weiyang@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig218C14563DE101D5441E54A5"
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62784 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097Ab3ETJhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 05:37:18 -0400
In-Reply-To: <1369037707-27026-2-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig218C14563DE101D5441E54A5
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/20/2013 01:15 AM, Wei Yang wrote:
> tx_ring/rx_ring size is assigned in function e1000_alloc_queues(), whic=
h is
> called by e1000_sw_init() in the early stage of e1000_probe().
>
> This patch just remove the duplicate assignment of this default ring si=
ze
> value.
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Da Yu Qiu <qiudayu@cn.ibm.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
Thanks, I have added the patch to my queue for e1000e.


--------------enig218C14563DE101D5441E54A5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRme7NAAoJEOVv75VaS+3O51EP/25CgilwCWwocfZcNYCcMRdE
g/th5x7leSH0u3txxMwT2AU7TX4iDf+DyLbTIivO7VcwE5qN0P7pOLHjey0xSmMG
jGIa03X9iV5M0h8MTkJ/nj5vVsfc4PxuS0ZbIqxPCGPlPFgxbPjSy8ncTMfESUo1
JFpip7QhjrFJRffQIi3+gCtOajkZOUYV82SybCZTjWmtBcsWRJX8Lr0o1yLg9j08
BF8UVNzvfSUbylqIZsdhwB236/Q+JUiPQwnHn+tzsdWZDwOjiDnOr/XXUtVahv/S
Q4W8GINMO6bzu4U6VU9Ykdky5fDpfQ2HgruWwo2/LAbTGtDvi1DzyvSxA4bWslSF
mE5gOEjfEpKiKoPNTDgOPhOt3TFGnzKV4FTClFIUX2MZxxG+KF4ceUUuIGDEAC0s
fz1cfVr2xmLX5Ep747AkYmPY6c0g/HDjv8Qp4h1g+ViSsj5q2c4plKpZ/ha94MD/
ulmygyC3bcGBay6jGzTkvNAKg1f/G5RPDO94Rq7AUk9tammpx7SGhlJ2n8nyxIB3
exR+xfQYDrTIWwQ1muhM0fEAKPdBDebxSclIS1dXJ5cbQp1TAS15D5eDq9UY0dRi
CO7WYVWzx6G/DlTRPacFnjxun3CQlDMtFjwaPeWt2X5JoBhfRwaWhxOwddxb1CDt
5ItFggAUD05xiwHxwd50
=tXbB
-----END PGP SIGNATURE-----

--------------enig218C14563DE101D5441E54A5--

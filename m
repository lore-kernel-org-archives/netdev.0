From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 03/10] e1000e: remove redundant if clause from
 PTP work
Date: Fri, 14 Mar 2014 16:17:24 -0700
Message-ID: <1394839044.2167.89.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-4-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TIUGumMRWdbvoTY4yoDI"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47769 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754478AbaCNXR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:17:28 -0400
In-Reply-To: <1394818481-7652-4-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TIUGumMRWdbvoTY4yoDI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> tx_hwtstamp_skb is always set before work is scheduled,
> work is cancelled before tx_hwtstamp_skb is set to NULL.
> PTP work cannot ever see tx_hwtstamp_skb set to NULL.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 3 ---
>  1 file changed, 3 deletions(-)

Thanks Jakub, I will add this patch to my queue.

--=-TIUGumMRWdbvoTY4yoDI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI44EAAoJEOVv75VaS+3OsfYP/1yP30sV0mZcXDRkz8uhhsOo
Ubww2rKOz70AtZ+88E76iMqLujCJOujurUtAFbU8+KtALAawf1oO7vxARI323VV1
rutmLnk3gD5p2fnQoUmifG8UZB6z6etwIrqL2WF4NL7AhfFSAs7nDD7DwE4nwkFH
qDEds961RqR09fz8rsrRIyVWBbYDWlQxpOQWm8vLG/WY7qzC7zs0ul78d5DIwGh6
7QpF4T6+LFI1OeKX+sHdAjH1z0aN3UpGFdU7uMX83ms22k/aTwxVA+4/HksaiMCQ
Wh09gpgMMEc5V3FLWhLIyNhYbHicRviJVOHdhQl8nxUOKbTLK/jyNazkBNQPx9FP
opiVFlnDzYSKDkEohBj7qN5ja96AcUa15yN4w2g0OKVHEQVdoaodoB+GWkipk5eg
2bGYi/BuZ0FvYVY2xxQAFVT5ao55yNaers4Fcd340B7cJBLzIOVz3+JBRh2x3xAd
vJzrpH5NBstqyf7o0aAeVxNZ+j8dekbX+Tv4tKAr3MPUyuqH7bSFBDDEwusVusYl
cLb3C5gofo5ua7eirIdJMFDZKYPOYmi8XeMDHjwb7VF/sQtbFV7iVv8MHptaFn93
vls/oQYlbaYdTb1PXh9kiDOwLMVPXC4ESOW4gAtlp6AXQBMqj9DrKGiXeW0BBV4j
FbryFzI1caEFSjoDBKM8
=mVKC
-----END PGP SIGNATURE-----

--=-TIUGumMRWdbvoTY4yoDI--

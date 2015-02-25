From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 net] e1000: add dummy allocator to fix race condition
 between mtu change and netpoll
Date: Wed, 25 Feb 2015 03:17:43 -0800
Message-ID: <1424863063.2553.52.camel@jtkirshe-mobl>
References: <1424862194-15770-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TyAhgow3z4BJ+rcy9xG1"
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26760 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbbBYLRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 06:17:54 -0500
In-Reply-To: <1424862194-15770-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TyAhgow3z4BJ+rcy9xG1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-25 at 12:03 +0100, Sabrina Dubroca wrote:
> @@ -4481,6 +4489,7 @@ next_desc:
>         return cleaned;
>  }
> =20
> +
>  /**
>   * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
>   * @adapter: address of board private structure

This added blank line is not needed or wanted.

--=-TyAhgow3z4BJ+rcy9xG1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU7a9XAAoJEOVv75VaS+3O85EP/0vhSE+bnajUYwOzOjp47KO8
L3D2kKjwtFXmos82EbXALYY+QVErCMgZE/dARoI2EOmihc7a2qlZwFTjs6FEH1gb
5R9NqDP9ey+bWejNUhM3TnrPxOrKccySW8pBc3gntMxPkG7xbJSgaNT2336jmxEG
XhUT+OGijaWqgBQWBddJ0h4j6baLvYzsmAfsD8ZrwBd5F9de9iYvBRs818ajC3qm
1i3Ab6K8l0pmVB4l+fcyR3stYT5c7pGYkjOQ5JsM5kl/dOBmouTLAofwmUe6NV7/
cMdLnrXr2dOJJO99ExR2FlL4BgtaoLlC5QUbgs6kWZIcBiVRGveRUAVlVH0QVC9+
569Evd3CQ8nEj12qEZpx2gp1GHKesHR7RLv1Pay2arT3Rv/imbFeUzinOC7vNPom
J9CAd+Y6YGuewCt97sWC/Lo23J907nYwE5/R9HJMutqov0xIha6Be39f+7tSmSiO
8fuiMxSENMN/PkQHPw3Ac+u8gOLRvnOWgsnHKX5NpgI/WvC5722jlmZRChGbDf2V
Kx0D0NA/UNyNk1ttAwVThzksF40fDqUo7PwBdsrG9BlxN8+rmhhEDCOfGNuKkVzN
0YjHanC+2Q5iD3P/mfs8Ju4/Abzzi7bzSPYGpBJuQG2oZXOFO/KvVt5Tp8ShPVQG
ajYzbDcBInVYAgCRke7y
=YJHY
-----END PGP SIGNATURE-----

--=-TyAhgow3z4BJ+rcy9xG1--

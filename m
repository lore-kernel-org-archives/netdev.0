From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 2/2] igb: Make arrays on stack static const to
 avoid reallocation
Date: Thu, 05 Mar 2015 11:27:15 -0800
Message-ID: <1425583635.2556.143.camel@jtkirshe-mobl>
References: <20150305192031.22228.75375.stgit@ahduyck-vm-fedora20>
	 <20150305192506.22228.28385.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qXAeMlDJt8E/Lws7ftw/"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6538 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbbCET1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 14:27:17 -0500
In-Reply-To: <20150305192506.22228.28385.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qXAeMlDJt8E/Lws7ftw/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-05 at 11:25 -0800, Alexander Duyck wrote:
> While addressing the pin problem I noticed that all of the pin
> register
> values where having to be pushed onto the stack each time the function
> was
> called.  To avoid that I am making them static const so that they
> should
> only need to be allocated once and we can avoid all the instructions
> to get
> them onto the stack..
>=20
> size before:
>    text    data     bss     dec     hex filename
>  161477   10512       8  171997
> 29fdd drivers/net/ethernet/intel/igb/igb.ko
>=20
> size after:
>    text    data     bss     dec     hex filename
>  161205   10512       8  171725
> 29ecd drivers/net/ethernet/intel/igb/igb.ko
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c |   24
> ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)

Thanks Alex, I have added your patch to my queue.

--=-qXAeMlDJt8E/Lws7ftw/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU+K4TAAoJEOVv75VaS+3O0H0P/jZWpq3X43IgmViboZ/lefNh
ZG0AXZAYXsFyFrNPVNAD9Obh/4dlOwifV0Wbf9M45eyXRs4fnbVZqrjEwiFX9PPm
LLcCsGrZiwhAyJHivKYNKMy0ksF2XUoe4/HWxQpgzxP8Wiy+DiVjmO7cWAOHd7yW
NKUjxJFp81vuYpJHoO1M/XrO7krij3AN0pYbWC4uvoOEw1fdSn3SPnUNCtg+SHJX
sHu0xeRSueFRyFo/sRZdFWlei5opur4xQEzdQoSD6+ibS6LOKqZ11r+0oFGpyWBA
7JWHJ25IDtvVkKtYnvXnZBBpgkOPB3QI13LosIxnsLfxRDOPHAMMzSBcxFLVHAbs
ne1gX/OFzbJhV/UIVP4ZaDBmFp6TjSqITW0w9BcaSt9iUyClnv0YWejAd4AtbpuQ
5ERkR9oZsEOYaBIWH9wLDsjT26wZZQLdqmFUrmwot+4vXD+QtSLYZzR394TqsU8O
p99XwtlUHlVP0ncllIkBqWIb1a4rZEpeW3Q2QSo2O5wN8veidC5/8i2JNPDI/CwE
7wUc6q8Dk9WVSn2GNX4zkojT2fGuyLnt0R1+CCP3ie0CukpwHJAorUD1uIVMqk6p
l04SciLoNscsQaXyiMSKJpKEI1U7dg8YN+Keu7CAIbN1IoSYij5vHPUzYn7sYyA3
141jYPVm5wh0fJPS/fIA
=jUO4
-----END PGP SIGNATURE-----

--=-qXAeMlDJt8E/Lws7ftw/--

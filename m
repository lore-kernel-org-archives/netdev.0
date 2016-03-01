From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] ethtool.h: define DIV_ROUND_UP for userland
Date: Tue, 01 Mar 2016 20:06:46 +0000
Message-ID: <1456862806.3098.161.camel@decadent.org.uk>
References: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
	 <20160301.114232.138387157898713379.davem@davemloft.net>
	 <1456852446.3098.157.camel@decadent.org.uk>
	 <20160301.144826.104748964516491333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ry3TD8zXzJqcU2RAJG5i"
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	nikolay@cumulusnetworks.com, kan.liang@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46445 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753007AbcCAUHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:07:03 -0500
In-Reply-To: <20160301.144826.104748964516491333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ry3TD8zXzJqcU2RAJG5i
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-01 at 14:48 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 01 Mar 2016 17:14:06 +0000
>=20
> > On Tue, 2016-03-01 at 11:42 -0500, David Miller wrote:
> >> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> Date: Tue,=C2=A0 1 Mar 2016 16:20:41 +0100
> >>=C2=A0
> >> > DIV_ROUND_UP and is defined in linux/kernel.h only for the kernel. I=
NT_MAX
> >> > needs limits.h in userland.
> >>=C2=A0
> >> It is wrong to provide a definition of this in the user visible global
> >> namespace.
> >=C2=A0
> > Which is why he's not doing that...
>=20
> No, that's exactly what he's doing:
>=20
> +#ifndef __KERNEL__
> +#include <limits.h> /* for INT_MAX */
> +#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
> +#endif
>=20
> in a uapi header file.
>=20
> "If not kernel, define DEV_ROUND_UP"

Sorry, as there was already a v2 which doesn't do this, I thought you
were responding to that.

Ben.

--=20
Ben Hutchings
If God had intended Man to program,
we'd have been born with serial I/O ports.

--=-Ry3TD8zXzJqcU2RAJG5i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtX2Vue/yOyVhhEJAQrccw//eFEJE023290a68cY+qu3YfNYrXq0LHQh
uMf+6xG07PtcInPyniSTWv7IoJY+7oIYI8MY2hNsmXuDxRJHQ83X33FOJCjOlSA9
5dKDSdx7q3b2RqrPcevvfE+KXpLCOkKikUPXMJG9Bnd1rbsaRmUFUc+xWxxgaB3S
DRLwX8nw5ChRpaMRIV9e72O37ay8+a+toGTSrVfcSuCckVTbMZfaE689Z1nMxWwK
Yq5IGh2KLn95rAPd3gD5Q5OLLOyOfaRIiCaUv6D3NYmRcxOr625rxjKt7KOQZEVN
+5MhQTPy2/H27U6Of1547CTlE/m9sr0wMF7iIAJpJOdbst2/FJbTOt0Nsw4l+/zF
nWRFeJAlDWKMNm8VdhzmmL855qFMWwgAecYEhkwUCht2VBEG4mrwoY/OzticwaQ2
+UDte+dtzXYWX3VTWhBXLYePB3VVMsGjk5BXXdZjomFwlyh/ImanBTrpmlKOKTVQ
FVabQj3tOhlaLTfpBiruGv02QxWVz5snsD4FxDRUW5JGFnejplwcrG1MQwCCFvZT
RjyI1+d979Et8yaNjPzrxE6faLKv3XoFSZCNR6rcScxl3EEhYqpauHHDoz/9IdXX
Vmh0kzH6DkIXRjGq+MceL0Qxmtfbv/TocQGJEUkrrcNjYNYNy0bUbVBDy3RjUgEj
tieIN6dyl2Y=
=5SM/
-----END PGP SIGNATURE-----

--=-Ry3TD8zXzJqcU2RAJG5i--

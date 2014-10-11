From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] fm10k: Add skb->xmit_more support
Date: Sat, 11 Oct 2014 04:14:43 -0700
Message-ID: <1413026083.2427.59.camel@jtkirshe-mobl>
References: <20141010213013.20973.19209.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ue+Vi+ERKdhcOHTk7mzH"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net, matthew.vick@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27309 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbaJKLOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:14:44 -0400
In-Reply-To: <20141010213013.20973.19209.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ue+Vi+ERKdhcOHTk7mzH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-10 at 14:30 -0700, alexander.duyck@gmail.com wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>=20
> This change adds support for skb->xmit_more based on the changes that
> were
> made to igb to support the feature.  The main changes are moving up
> the
> check for maybe_stop_tx so that we can check netif_xmit_stopped to
> determine
> if we must write the tail because we can add no further buffers.
>=20
> Acked-by: Matthew Vick <matthew.vick@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>=20
> v2: Minor fix to patch description for typo.
>=20
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |   65
> +++++++++++++------------
>  1 file changed, 34 insertions(+), 31 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Its like you never left Intel Alex... :-)
Dave, please pull this.

--=-Ue+Vi+ERKdhcOHTk7mzH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUOREjAAoJEOVv75VaS+3OzpcQAIrWCl39xTcwany5y32aYZNa
1arzefszhU/amLInXA+TtVa5o9Z2UFphpIlWDXvBq6H8RQF7+azSYMNU9y1pfa5J
xDEsmgE0qe94D5/nuepkPf74TZN3jCzvGMUROvv1XiwubdiE2JfnTvDKPtLmjCwW
DhwoFa0lNahjfBwxDjUlmptUWSsZrscvqdT4fOLCITcdf3gWwNS1yvRI+RrRbgu3
e5rv2zbT8T//m/DWH1cszpPewqSyJLrAPm6xQmWaSCVF4rB1D3r9MxR12tEwdXAn
q8jhgtjIn4/hzPXa5A9Lt8CMheOjedXh06azcst8r4aRNxRrMAGTkSEDjrqL2PhV
BWdtohKX+ycJqdwqZq4TLVifg4FcPnqLUfGg7dfgPeVQxH+s7adge7jNAIykHkhZ
NtDDt/vBqMIJNpfIYntx3BcOlcagxseU8pj5Mkv3EeLeXZ9yhs+y1Qz5Bg3u1OwG
knVjqU7WLP0p4F3EIMLxkaA2TAcCZaQLdLVDrKq6itFm9fkxUBydzS2K/Ju2S/q+
NnyfffZ+Ewn3YKA5B7KI3JkoOVBfK943XHh3vC7ODQQa11jM/gh8JCKZvElxB7oe
ElP/LhUOPuQiUzMd1GWswF6hDgsjwPm8ypN92zDJT3Z7SCxfqdY3vMaKp3FoVWMS
ToS4a7WmCK0mRUFHtsCX
=xj4g
-----END PGP SIGNATURE-----

--=-Ue+Vi+ERKdhcOHTk7mzH--

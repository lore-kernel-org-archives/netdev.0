From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v1 1/2] ethtool: minor doc update
Date: Fri, 18 Mar 2016 00:29:28 +0000
Message-ID: <1458260968.3431.0.camel@decadent.org.uk>
References: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
	 <1458259436-85275-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-V+AoYTaMdMZKcAZu9y/r"
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Decotigny <decot@googlers.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	David Herrmann <dh.herrmann@gmail.com>
To: David Decotigny <ddecotig@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59529 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbcCRA3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 20:29:37 -0400
In-Reply-To: <1458259436-85275-2-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-V+AoYTaMdMZKcAZu9y/r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-03-17 at 17:03 -0700, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> Updates: commit 793cf87de9d1 ("ethtool: Set cmd field in
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ETHTOOL_GLINKSETTIN=
GS response to wrong nwords")
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> =C2=A0include/uapi/linux/ethtool.h | 6 +++---
> =C2=A01 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 2835b07..9222db8 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1648,9 +1648,9 @@ enum ethtool_reset_flags {
> =C2=A0 *	%ETHTOOL_GLINKSETTINGS: on entry, number of words passed by user
> =C2=A0 *	(>=3D 0); on return, if handshake in progress, negative if
> =C2=A0 *	request size unsupported by kernel: absolute value indicates
> - *	kernel recommended size and cmd field is 0, as well as all the
> - *	other fields; otherwise (handshake completed), strictly
> - *	positive to indicate size used by kernel and cmd field is
> + *	kernel expected size and all the other fields but cmd
> + *	are 0; otherwise (handshake completed), strictly positive
> + *	to indicate size used by kernel and cmd field stays
> =C2=A0 *	%ETHTOOL_GLINKSETTINGS, all other fields populated by driver. Fo=
r
> =C2=A0 *	%ETHTOOL_SLINKSETTINGS: must be valid on entry, ie. a positive
> =C2=A0 *	value returned previously by %ETHTOOL_GLINKSETTINGS, otherwise
--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer
--=-V+AoYTaMdMZKcAZu9y/r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW60voAAoJEOe/yOyVhhEJF5QP/2iTwg8ck6eIe4CaADd9jlwe
FOvh194fBi4etaZmKnT/gaecSrM0iwvavO/9rKepbs1LqtLfazt6meRaRmdJLdfo
FN2aSm0usdzRbobjcFvn34SXRQ3ARXjnTRaOQI2bSoP9sGkak8HR8/ttR8W3rGgr
hWSrPHUVvMSrIQmq1z3gvaV2p1sI796ABDh7UVcFMhLo85ZCooT3LXc28+t/Ibxr
dCbw0I4X2EkAUHCq2R2q0So312drm3FesM+Rr9TCSG/FkOxZtzJd48XDkR5ciEvf
Vbos/+2tVe4+20h+kGymdFu+77glH2M19Qg52p3JYbAtuIh/7DPrt7bH29V73Av4
dygLSpcfhHNk5fpGjgQ2vKh2sO/ecVPXPryf39UE3BPfbceNHp9tP8Z7pKIR6wB7
bJgt1+2o0AzHPIw1scyHwBYUIH1qJmKjqJ+/tcW2YeeNQs9zG/xpP0puYMbOrayd
2y0KT3Y9mA1wssdecAvoTVUCbUBD9iGiDm+d5JaWonGSGaQPCiWAmjodMFm+4Fv0
DZXIQheLUIRLkYgZ1aW1nSRx8fUVTT28+EoOCA2/K/bSIkx9W7/l4urOcVDQ9YXm
CtFLDa2U5c9DXQNwgWNat58CvvFtJ9X9fGK9WM5ggFjXNXEsanh4VbW/EDWXrcpa
awM1DzkyiRwAEr/R+Zrr
=Mkr5
-----END PGP SIGNATURE-----

--=-V+AoYTaMdMZKcAZu9y/r--

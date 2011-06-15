From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 2/2] batman-adv: compare_eth() should take const pointer arguments
Date: Wed, 15 Jun 2011 07:56:08 +0200
Message-ID: <201106150756.10117.sven@narfation.org>
References: <20110614235132.3724.57632.stgit@warthog.procyon.org.uk> <20110614235142.3724.92963.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6415492.DeiPKRp8Ju";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:50212 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab1FOF4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 01:56:13 -0400
In-Reply-To: <20110614235142.3724.92963.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart6415492.DeiPKRp8Ju
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

David Howells wrote:
> compare_eth() should take const pointer arguments so that it can be passed
> const pointers without the need for a cast, leading to:
>=20
> net/batman-adv/vis.c: In function 'vis_data_insert_interface':
> net/batman-adv/vis.c:146: warning: passing argument 2 of 'compare_eth'
> discards qualifiers from pointer target type
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Marek Lindner <lindner_marek@yahoo.de>
> cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
> cc: Sven Eckelmann <sven@narfation.org>
> cc: b.a.t.m.a.n@lists.open-mesh.org
> cc: netdev@vger.kernel.org
> ---
>=20
>  net/batman-adv/main.h |    2 +-
>  net/batman-adv/vis.c  |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
> index 148b49e..e6fc798 100644
> --- a/net/batman-adv/main.h
> +++ b/net/batman-adv/main.h
> @@ -172,7 +172,7 @@ static inline void bat_dbg(char type __always_unused,
>   *
>   * note: can't use compare_ether_addr() as it requires aligned memory
>   */
> -static inline int compare_eth(void *data1, void *data2)
> +static inline int compare_eth(const void *data1, const void *data2)
>  {
>  	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
>  }
> diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
> index c39f20c..34053ac 100644
> --- a/net/batman-adv/vis.c
> +++ b/net/batman-adv/vis.c
> @@ -143,7 +143,7 @@ static void vis_data_insert_interface(const uint8_t
> *interface, struct hlist_node *pos;
>=20
>  	hlist_for_each_entry(entry, pos, if_list, list) {
> -		if (compare_eth(entry->addr, (void *)interface))
> +		if (compare_eth(entry->addr, interface))
>  			return;
>  	}

Sry, but this patch doesn't apply here (net-next-2.6/linux-next)

Kind regards,
	Sven

--nextPart6415492.DeiPKRp8Ju
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJN+El5AAoJEF2HCgfBJntGi98QAKSvOwMaJraCxyLkwwZutlse
RFWePTrfMYlmZqE+nShd9PaQmLFwH0jfOo9efka7lomy0HL37/SbAOlWZjsvt/8a
IybENol7QjY2mk4SEeEfEzDHaTF+hZcJDOoHKwK6iQ9MNzPsMRjdfJSNW1y98Arp
Ax04f80WKPWHJSEdN+Kh7wcdV9MEUy+qwmb2WTiMTawLuO2G80086LACaibfxXrK
82jiwmFCtSstqmc/LLvaJM2vuSMYVRLBa0rlRY491xX6HroMuYahcl9kIAEjgfls
7PzgrMlpIThNaxxCLTZylXAhtrRa6ufIiuW9zd9BAdQ1pqRtVPqKg05callFDUZd
4ZNT5zqM3aPFKFCq1MzGYIXyu23JdEQgFZ3CCKoSbBizsMEiMavDB1+ubIppLFwY
WIozx/jTBr+QTlRO60JceRoYeX5mL1iFwHZ9bNEeOfYuCAdYSs5gnPBhnroymh5f
B2PDJF6DOwJrT5OdEgmUg6tgshx18MzlrQzH3LwTFM3NHn6ipCoVwLy5DJfscPTf
Fni/0dUUHaqiKTre5sqnQsZfRjktJsmf7+S4GP0im3HGdcLhm2/rZ9pAB1qfFoYW
SEpmDx1v8rURrHpipTDtomM1ge+3tE9EeWnlshYc9O8Q80Za71zZAwhVx+wnFbFg
kRRk6rvbct9iI6mfqgHe
=oB+4
-----END PGP SIGNATURE-----

--nextPart6415492.DeiPKRp8Ju--

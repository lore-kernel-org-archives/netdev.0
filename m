From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 06/39] genetlink: export genl_unregister_mc_group()
Date: Thu, 27 Nov 2008 00:07:50 +0100
Message-ID: <1227740871.3809.0.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <ffc312e09e5728d546c67dd26aa1f53bacc3b0f1.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-htA6ogKIVfxTm4GqWHLX"
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org,
	Thomas Graf <tgraf@suug.ch>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52319 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbYKZXI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:08:29 -0500
In-Reply-To: <ffc312e09e5728d546c67dd26aa1f53bacc3b0f1.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-htA6ogKIVfxTm4GqWHLX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 14:40 -0800, Inaky Perez-Gonzalez wrote:
> Add an EXPORT_SYMBOL() to genl_unregister_mc_group(), to allow
> unregistering groups on the run. EXPORT_SYMBOL_GPL() is not used as
> the rest of the functions exported by this module (eg:
> genl_register_mc_group) are also not _GPL().
>=20
> Cleanup is currently done when unregistering a family, but there is
> no way to unregister a single multicast group due to that function not
> being exported. Seems to be a mistake as it is documented as for
> external consumption.
>=20
> This is needed by the WiMAX stack to be able to cleanup unused mc
> groups.

Haven't looked at the users, but you definitely need that as soon as you
need to unregister a group on the fly, so obviously

Acked-by: Johannes Berg <johannes@sipsolutions.net>

> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> ---
>  net/netlink/genetlink.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 3e1191c..1d3dd30 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -225,6 +225,7 @@ void genl_unregister_mc_group(struct genl_family *fam=
ily,
>  	__genl_unregister_mc_group(family, grp);
>  	genl_unlock();
>  }
> +EXPORT_SYMBOL(genl_unregister_mc_group);
> =20
>  static void genl_unregister_mc_groups(struct genl_family *family)
>  {

--=-htA6ogKIVfxTm4GqWHLX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIbBAABAgAGBQJJLdbBAAoJEKVg1VMiehFYhfgP+L6F6sJmytqZRek14eWcMJbW
bjhDaSiy44SjquBV6hT03QsrPeTACg/UETMmxKZ691X4DtnbTBMXvY9ndpBhJmK3
zT1YZuDQY1V9XvP3F/DwVMwIZlvnRnJMCCNYAi3diBz83/IVJXZKx5+XxuPO4y1l
hOL08aqedXC44Yh9JQhns4yKWgBiI8NMe1lkt3f5nE6Mx2i/5eoM+QrWL+09zzyl
gucraOkrGS24ETHnyiULwQc8QdKQPlRIiDB/pHtlwPPI6cZeLJ085AAvZpzSIqNC
ETYrKO97JLtMA8egr8gFQfU772WzJbHJ1EYmjr+0/IL204ndn9A3j0IE0zcxausu
s4Eanp6nETwIVtsP46xEyI7lWKE6sSuojE/VM4fT85qHTJz4mbSBlMLQmAoAysB9
2882VA8YPe9ZnPmnut8piS8SP4W0BuhbR4WCj8rRbW4E9Qs8k1+1+IUycg7jrF3J
Zl0Ugx8Y8+5/doE6R96ly+sL4r6TyuA+1m+MGLn6+mEypi8fVBzqiAKNWo7+XFqq
90l6BQAv6B1WYNWgEPKRzKi+s6At+7K0aKZItfN1spr+9Pu+QBRzRPxW2KuS/5pg
+eqYDINoiJNLkMaZJYjpF1WUYqNG3lQg7kVsziIFga4DXAlDauSgwoWT4IcEEU8q
qvtWQIwuRX2eyCjdAcw=
=1I/B
-----END PGP SIGNATURE-----

--=-htA6ogKIVfxTm4GqWHLX--


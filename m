From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] [NETFILTER] xt_policy.c: kill some bloat
Date: Sat, 12 Jan 2008 03:23:18 -0800 (PST)
Message-ID: <20080112.032318.201654370.davem@davemloft.net>
References: <12001304703362-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001304703302-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001304703789-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762693AbYALLXT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 06:23:19 -0500
In-Reply-To: <12001304703789-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 12 Jan 2008 11:34:27 +0200

Ilpo, please post netfilter patches to netfilter-devel,
CC:'ing Patrick McHardy.

Patrick, please review, thanks.

> net/netfilter/xt_policy.c:
>   policy_mt | -906
>  1 function changed, 906 bytes removed, diff: -906
>=20
> net/netfilter/xt_policy.c:
>   match_xfrm_state | +427
>  1 function changed, 427 bytes added, diff: +427
>=20
> net/netfilter/xt_policy.o:
>  2 functions changed, 427 bytes added, 906 bytes removed, diff: -479
>=20
> Alternatively, this could be done by combining identical
> parts of the match_policy_in/out()
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/netfilter/xt_policy.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
> index 46ee7e8..45731ca 100644
> --- a/net/netfilter/xt_policy.c
> +++ b/net/netfilter/xt_policy.c
> @@ -33,7 +33,7 @@ xt_addr_cmp(const union xt_policy_addr *a1, const u=
nion xt_policy_addr *m,
>  	return false;
>  }
> =20
> -static inline bool
> +static bool
>  match_xfrm_state(const struct xfrm_state *x, const struct xt_policy_=
elem *e,
>  		 unsigned short family)
>  {
> --=20
> 1.5.0.6
>=20

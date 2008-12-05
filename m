From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] dccp: use roundup instead of opencoding
Date: Fri, 05 Dec 2008 21:47:43 +0000
Message-ID: <1228513664.3520.68.camel@achroite>
References: <Pine.LNX.4.64.0812052342180.3726@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:39624 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755574AbYLEVrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 16:47:47 -0500
In-Reply-To: <Pine.LNX.4.64.0812052342180.3726@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-05 at 23:43 +0200, Ilpo J=C3=A4rvinen wrote:
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/dccp/output.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/dccp/output.c b/net/dccp/output.c
> index fea30cd..1b75ece 100644
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -175,7 +175,7 @@ unsigned int dccp_sync_mss(struct sock *sk, u32 p=
mtu)
>  	 * make it a multiple of 4
>  	 */
> =20
> -	cur_mps -=3D ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
> +	cur_mps -=3D roundup(5 + 6 + 10 + 6 + 6 + 6);

Maybe you should check that with your compiler.

Ben.

>  	/* And store cached results */
>  	icsk->icsk_pmtu_cookie =3D pmtu;
> --=20
> 1.5.2.2
--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


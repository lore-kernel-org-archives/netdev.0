From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Fix compilation error in ip_vs.h for
 ip_vs_confirm_conntrack function.
Date: Fri, 21 Oct 2011 10:25:13 +0900
Message-ID: <20111021012513.GA24998@verge.net.au>
References: <1319113084-7498-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43923 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab1JUBZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 21:25:17 -0400
Content-Disposition: inline
In-Reply-To: <1319113084-7498-1-git-send-email-krzysztof.wilczynski@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2011 at 01:18:04PM +0100, Krzysztof Wilczynski wrote:
> This is to address the following error during the compilation:
>=20
>   In file included from kernel/sysctl_binary.c:6:
>   include/net/ip_vs.h:1406: error: expected identifier or =E2=80=98(=E2=
=80=99 before =E2=80=98{=E2=80=99 token
>   make[1]: *** [kernel/sysctl_binary.o] Error 1
>   make[1]: *** Waiting for unfinished jobs....
>=20
> That manifests itself when CONFIG_IP_VS_NFCT is undefined in .config =
file.
>=20
> Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
> ---
>  include/net/ip_vs.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 139784e..de527d1 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1395,7 +1395,7 @@ static inline void ip_vs_update_conntrack(struc=
t sk_buff *skb,
>  {
>  }
> =20
> -static inline int ip_vs_confirm_conntrack(struct sk_buff *skb);
> +static inline int ip_vs_confirm_conntrack(struct sk_buff *skb)
>  {
>  	return NF_ACCEPT;
>  }

Thanks Krzysztof,

that fixes a brown paper bag effort from me.

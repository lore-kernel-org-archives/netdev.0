From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix ipv6 fragment ID selection at slow path
Date: Mon, 03 Oct 2005 10:18:26 +1000
Message-ID: <E1EME2E-0006dR-00@gondolin.me.apana.org.au>
References: <433FED06.8070806@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	roque@di.fc.ul.pt
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932082AbVJCASk@vger.kernel.org>
To: yzcorp@gmail.com (Yan Zheng)
In-Reply-To: <433FED06.8070806@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yan Zheng <yzcorp@gmail.com> wrote:
> 
> --- linux-2.6.13.2/net/ipv6/ip6_output.c        2005-09-17 09:02:12.000000000 +0800
> +++ linux/net/ipv6/ip6_output.c 2005-10-02 22:12:54.000000000 +0800
> @@ -701,7 +701,7 @@
>                 */
>                fh->nexthdr = nexthdr;
>                fh->reserved = 0;
> -               if (frag_id) {
> +               if (!frag_id) {
>                        ipv6_select_ident(skb, fh);
>                        frag_id = fh->identification;
>                } else

This patch makes sense to me.

Please add a Signed-off-by line and send the patch to
davem@davemloft.net and yoshfuji@linux-ipv6.org.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 15:32:13 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407251532.13292.kazunori@miyazawa.org>
References: <20040724083709.GA9416@gondor.apana.org.au> <200407250410.03741.kazunori@miyazawa.org> <20040725080347.GA20251@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040725080347.GA20251@gondor.apana.org.au>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2004/07/25(日) 17:03、Herbert Xu  wrote:
> On Sun, Jul 25, 2004 at 04:10:03AM +0900, Kazunori Miyazawa wrote:
> > To process routing header correctly, we should fix the codes which
> > calls ip6_dst_lookup in ipv6 because there is difference of destinatio
> > addresses for routing resolution and looking up xfrm_policy.
>
> What do you mean? Isn't the code in icmp.c/raw.c/tcp_ipv6.c/udp.c
> that sets fl.fl6_dst using opt->srcrt enough?
>
> If not then we'll need to change IPv4 as well.
>
routing is looked up with srcrt but xfrm is looked up with final
destination, isn't it? we have the codes in our repository.
sorry, I'm goring back to home from OLS2004.
I'll send the patch when I will arrive at home.

Thank you,

--Kazunori Miyazawa

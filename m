From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 04:10:03 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407250410.03741.kazunori@miyazawa.org>
References: <20040724083709.GA9416@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040724083709.GA9416@gondor.apana.org.au>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2004/07/24(土) 17:37、Herbert Xu  wrote:
> Hi:
>
> This patch rearranges the IPv6 routing header so that the destination
> addresses appear in the order as they would on the destination.  This
> is specified in Appendix A2 of RFC 2402.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>

To process routing header correctly, we should fix the codes which
calls ip6_dst_lookup in ipv6 because there is difference of destinatio 
addresses for routing resolution and looking up xfrm_policy.
So, we needs to separate ip6_dst_lookpu and xfrm_lookup.
I will send the patch later.

Thank you,

--Kazunori Miyazawa

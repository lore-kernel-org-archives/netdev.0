From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 02:22:22 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407250222.22934.kazunori@miyazawa.org>
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
> Cheers,

I saw roughly the packet.
It needs to check direction of the process.
We don't need to do that in INBOUND.

--Kazunori Miyazawa

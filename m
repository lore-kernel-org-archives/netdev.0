From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Trivial fix for out of bounds array access in xfrm4_policy_check
Date: Tue, 07 Sep 2004 22:46:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C4fMc-000817-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.61.0409071322100.8637@hosting.rdsbv.ro>
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: util@deuroconsult.ro (Catalinux aka Dino BOIE)
In-Reply-To: <Pine.LNX.4.61.0409071322100.8637@hosting.rdsbv.ro>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Catalinux aka Dino BOIE <util@deuroconsult.ro> wrote:
> 
> Coverity found a bug in accessing xfrm4_policy_check using XFRM_POLICY_FWD 
> (=2) as index in sk->sk_policy.
> 
> sk->sk_policy[] is defined in sock.h as:
> 
> struct xfrm_policy *sk_policy[2];
> 
> Attached is the fix.

This is bogus as if the packet is forwarded then sk == NULL.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

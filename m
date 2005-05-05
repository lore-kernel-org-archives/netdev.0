From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops in ip_rcv
Date: Thu, 05 May 2005 21:40:54 +1000
Message-ID: <E1DTeis-0005gu-00@gondolin.me.apana.org.au>
References: <20050505101542.GB7916@krispykreme>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org (Anton Blanchard)
In-Reply-To: <20050505101542.GB7916@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard <anton@samba.org> wrote:
> 
> Im booting a recent 2.6.12-rc3++ git tree on ppc64. Just got an oops
> very early in boot, right after:
> 
> TCP established hash table entries: 131072 (order: 9, 2097kernel:
> 
> It looks like we tried to load from address -1.
> 
> c0000000003c515c ip_rcv+0x4c/0x6e0

Any idea why you'd be receiving packets this early?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Add missing newline for skb_*_panic
Date: Fri, 22 Apr 2005 09:50:52 +1000
Message-ID: <20050421235052.GA10371@gondor.apana.org.au>
References: <20050421050815.GA23133@gondor.apana.org.au> <42682527.3000709@trash.net> <42682718.3060601@trash.net> <20050421231437.GA10119@gondor.apana.org.au> <42683662.6060003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42683662.6060003@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 01:25:22AM +0200, Patrick McHardy wrote:
> 
> BTW, Do you know if that ppp problem (Fw: [Bugme-new] [Bug 4381] New:
> When i try to start a pppoe conn., crash at net/core/skbuff.c:91) was
> already fixed? Otherwise I'd suggest that the reporter should capture
> a crash again with this patch applied.

Unfortunately the reporter says that he can't reproduce it.

However, I have the suspicion that this is really the same as the
vpnc/tun bug (4279) that prompted you to make the self-modification
fix to tun.c.

Now there is no doubt that your patch fixed a real bug in tun.c.
However, I don't think it could have caused the crash in 4279.
The reason is that the crash dump shows that the length that
was supplied to skb_put is in fact positive (0xe4 in one case
and 0xf4 in another).

As soon as I get confirmation from the submitter that he can
still reproduce this I'll get him to try your debugging patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

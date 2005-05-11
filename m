From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (122)
Date: Thu, 12 May 2005 08:22:10 +1000
Message-ID: <20050511222210.GA21280@gondor.apana.org.au>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp> <20050510220751.GA459@gondor.apana.org.au> <20050511005836.GA1674@gondor.apana.org.au> <4282846F.6070403@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <4282846F.6070403@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 12:17:19AM +0200, Tommy Christensen wrote:
> 
> I actually thought this was caused by another race. More on that later.

Please elaborate.
 
> What about an alternative fix, that avoids even more cloning (where
> possible)? This resurrects the skb_orphan call that was moved out, last
> time we had 'shared-skb troubles'. It is practically a no-op in the
> common case, but still prevents the possible race with recvmsg.
> (And I have a weakness for one-line-fixes). :-)

Yep this is much better.  Thanks Tommy.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

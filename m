From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: networking-related oopses on 2.6.9
Date: Sat, 29 Jan 2005 09:25:20 +1100
Message-ID: <E1CueYJ-0000nX-00@gondolin.me.apana.org.au>
References: <20050128140836.GA10777@wonderland.linux.it>
Cc: linuxppc-dev@ozlabs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: md@Linux.IT (Marco d'Itri)
In-Reply-To: <20050128140836.GA10777@wonderland.linux.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marco d'Itri <md@linux.it> wrote:
> 
> I have been able to capture the latest two oopses from the serial
> console, is this a known problem?
> 
> KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tc

Yes these are known problems which should be fixed in 2.6.10.  However,
there is at least one other similar issue in 2.6.10 so you'll either
want to stay with 2.6.6 or go up to the latest bk snapshot.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

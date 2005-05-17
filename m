From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 09:08:33 +1000
Message-ID: <20050517230833.GA26604@gondor.apana.org.au>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050517.151352.41634495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517.151352.41634495.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 03:13:52PM -0700, David S. Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 18 May 2005 08:11:01 +1000
> 
> > Instead of measuring the distance using time, let's measure it
> > in terms of packet counts.  So every time we receive a fragmented
> > packet, we find all waiting fragments with the same src/dst pair.
> > If the id is identical we perform reassembly, if it isn't we increase
> > a counter in that fragment.  If the counter exceeds a threshold,
> > we drop the fragment.
> 
> And you protect against purposefully built malicious fragments how?

Is it any worse than what we've got now?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

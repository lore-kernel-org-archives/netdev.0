From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NATT] Fix uh->len with IP options
Date: Sat, 10 Jul 2004 11:21:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710012153.GA11236@gondor.apana.org.au>
References: <20040709114802.GA13344@gondor.apana.org.au> <20040709170502.58a05039.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040709170502.58a05039.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 09, 2004 at 05:05:02PM -0700, David S. Miller wrote:
> 
> At first I thought you should be using top_iph to compute the options
> length, but now I see why it's correct to be using 'iph'.

Mea culpa.  This is broken in tunnel mode.

My big patch that moves the tunnel code out will fix this since it
gets rid of iph altogether.

But if you want to hold out on that one for a bit then please make
the obvious fix by changing iph to top_iph.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Sun, 17 Oct 2004 17:39:57 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017073957.GA21632@gondor.apana.org.au>
References: <20041016113006.GA12843@gondor.apana.org.au> <20041016235137.GE19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, hadi@cyberus.ca,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20041016235137.GE19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 17, 2004 at 01:51:37AM +0200, Thomas Graf wrote:
> > So here is my proposal: if we detect signs of impending congestion
> > in netlink_broadcast(), and that we're in a sleepable context, then
> > we yield().
> 
> Up to how many receivers does that work? We would still see the
> effect if too many receivers are registered, right?

Assuming the scheduler is fair then every listener should get their
time slice to receive the messages.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

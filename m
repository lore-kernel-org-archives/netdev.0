From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Sun, 17 Oct 2004 22:42:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CJAMU-0006eR-00@gondolin.me.apana.org.au>
References: <20041017110807.GV21977@postel.suug.ch>
Cc: herbert@gondor.apana.org.au, pablo@eurodev.net, hadi@cyberus.ca,
        davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20041017110807.GV21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> 
> Assuming there is only a few listeners per process. I tried it out and
> my UP system could handle 7 listeners in the same process but would
> sporadically overrun above. I couldn't reproduce it with 1 listener
> per process anymore.

Please recall what I said in my original message:

: Before we start please bear in mind that netlink is fundamentally
: an *unreliable* protocol.  This is the price we pay in order to use
: it in all the contexts that we do.  So what we're looking for here
: is not how to make netlink 100% reliable, but what we can do to
: improve the quality of its implementation.

Having 7 listeners in the same process isn't really the killer application
I was looking for :)

> Therefore I guess this is fine for now, the problem might appear again
> if someone finally writes the netlink daemon to solve the locking
> problems.

I don't think I understand what you are referring to.  Could you
please elaborte?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

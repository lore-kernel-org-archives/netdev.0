From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 12:46:14 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928024614.GA9911@gondor.apana.org.au>
References: <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040923120707.GB32624@gondor.apana.org.au> <1095995042.1044.34.camel@jzny.localdomain> <20040924032440.GB6384@gondor.apana.org.au> <1096289189.1075.37.camel@jzny.localdomain> <20040927213607.GD7243@gondor.apana.org.au> <1096339407.8660.33.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096339407.8660.33.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 10:43:27PM -0400, jamal wrote:
> On Mon, 2004-09-27 at 17:36, Herbert Xu wrote:
> 
> > You still haven't told me what you're going to use 3) for yet...
> 
> Sorry, keep forgetting to retrieve it from other remote non-networked
> test machine. The idea is:
> Create something that generates lots of messages. Make socket buffer
> small (4096 is good nuf)

No that's not what I meant.  What I mean is what is the real-world
scenario where you're going to be doing 3).

Only when we know where the messages are coming from and what they
are can we decide on a meaningful method of limiting their rate.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

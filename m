From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 21 Sep 2004 07:59:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920215906.GA26266@gondor.apana.org.au>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net> <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414F1E12.6010808@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 08:14:42PM +0200, Pablo Neira wrote:
> 
> jamal wrote:
>
> >Agreed.
> >For a test i typically have something adding say 10K items (actions in
> >my case, but could be ipsec policies) and then try to dump them. On my
> >xeon i get an overrun after about 6K items are dumped.

Good.  That's something we can look at easily.  Dumping is meant to
be self-controlling as each packet naturally stops the next one from
being sent until the user has done a recvmsg.

> yes, this is exactly what I've observed.
> 
> Here a link to the tool that I use to stress netlink sockets.
> 
> http://eurodev.net/~pablo/netlinkbench-unicast-1.0.tar.gz

Thanks for the link.  I'll take a look.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

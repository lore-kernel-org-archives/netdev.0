From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 09:17:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919231734.GA10124@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net> <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095633569.1047.107.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 06:39:29PM -0400, jamal wrote:
> 
> Theres one valuable piece in his patch. Ability to congestion control
> the kernel so user space can clear the socket queue. The alternative is
> an overun. You have shot a hole in the workqueue approach. May i also

Congestion control would be a good alternative to overruns.  I too would
love to see netlink made more reliable if possible.  But hopefully without
sacrificing the good bits in it like performance.

However, in the scenarios that's been cited so far I can't see how it can
work.  For example, in the ip_queue context, the kernel really doesn't
have any alternative to dropping the packet, right?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

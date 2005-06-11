From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 05:32:34 +1000
Message-ID: <E1DhBic-0005dp-00@gondolin.me.apana.org.au>
References: <20050611074350.GD28759@alpha.home.local>
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: willy@w.ods.org (Willy Tarreau)
In-Reply-To: <20050611074350.GD28759@alpha.home.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Willy Tarreau <willy@w.ods.org> wrote:
> 
> During this, the client cannot connect to www.kernel.org from this port
> anymore :
>  wks$ printf "HEAD / HTTP/1.0\r\n\r\n" | nc -p 10000 204.152.191.5 80; echo "ret=$?"
>  ret=1

What if you let the client connect from a random port which is what it
should do?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

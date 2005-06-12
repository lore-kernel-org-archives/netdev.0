From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 20:30:20 +1000
Message-ID: <20050612103020.GA25111__14622.7939207622$1118572371$gmane$org@gondor.apana.org.au>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au> <20050611195144.GF28759@alpha.home.local> <20050612081327.GA24384@gondor.apana.org.au> <20050612083409.GA8220@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
Content-Disposition: inline
In-Reply-To: <20050612083409.GA8220@alpha.home.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2005 at 10:34:09AM +0200, Willy Tarreau wrote:
>
> > Sorry but this patch is pointless.  If I wanted to prevent you from
> > connecting to www.kernel.org 80 and I knew your source port number
> > I'd be directly sending you fake SYN-ACK packets which will kill
> > your connection immediately.
> 
> Only if your ACK was within my SEQ window, which adds about 20 bits of
> random when my initial window is 5840. You would then need to send one
> million times more packets to achieve the same goal.

Nope, no sequence validity check is made on the SYN-ACK.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

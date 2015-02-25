From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Ottawa and slow hash-table resize
Date: Wed, 25 Feb 2015 21:56:37 +1300
Message-ID: <20150225085637.GB2982@gondor.apana.org.au>
References: <20150224103918.GJ3713@acer.localdomain>
 <20150224.120944.866231994361475327.davem@davemloft.net>
 <20150224175014.GA29802@casper.infradead.org>
 <20150224.132603.842251066562193899.davem@davemloft.net>
 <20150224184502.GB10713@cloud>
 <20150224223409.GA1199@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh@joshtriplett.org, David Miller <davem@davemloft.net>,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	alexei.starovoitov@gmail.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150224223409.GA1199@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 10:34:09PM +0000, Thomas Graf wrote:
>
> There is a side effect. We can't grow the number of bucket locks more
> than 2x if we grow the table itself faster than 2x. So if we start
> out with a table size of 512 and grow 4 times in a row we will end
> up with a theoretical max bucket locks of 4K. Probably enough though.

Does this limit on bucket locks apply to my rehash scheme?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

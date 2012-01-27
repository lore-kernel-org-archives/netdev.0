From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/3] sha512: reduce stack usage even on i386
Date: Sat, 28 Jan 2012 09:32:50 +1100
Message-ID: <20120127223250.GA9384@gondor.apana.org.au>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com> <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com> <20120118180210.GA22733@p183.telecom.by> <20120126023502.GA10696@gondor.apana.org.au> <20120127175130.GA742@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120127175130.GA742@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2012 at 08:51:30PM +0300, Alexey Dobriyan wrote:
>
> I think this is because your tree contained "%16" code instead if "&15".
> Now that it contains "&15" it should become applicable.

OK.

> --------------------------------------------------------------------------
> [PATCH] sha512: reduce stack usage even on i386

Can you try the approach that git takes with using asm to read
and write W (see previous email from Linus in respone to my push
request)? As it stands your patch is simply relying on gcc's
ability to optimise.  At least with asm volatile we know that
gcc will leave it alone.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

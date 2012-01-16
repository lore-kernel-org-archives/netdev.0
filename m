From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Mon, 16 Jan 2012 11:37:34 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF45@saturn3.aculab.com>
References: <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Alexey Dobriyan" <adobriyan@gmail.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	<linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	<ken@codelabs.ch>,
	"Steffen Klassert" <steffen.klassert@secunet.com>,
	<security@kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> By the way, I suspect previous code was chosen years ago because this
> version uses less stack but adds much more code bloat.
> 
> size crypto/sha512_generic.o crypto/sha512_generic_old.o
>    text	   data	    bss	    dec	    hex	filename
>   17369	    704	      0	  18073	   4699	crypto/sha512_generic.o
>    8249	    704	      0	   8953	   22f9	
> crypto/sha512_generic_old.o

I wonder what the difference in execution times is?
I know this is very dependant in the actual cpu
and the cold/warm cache state...

But some measurements might be useful.

	David

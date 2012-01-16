From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Mon, 16 Jan 2012 09:56:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
References: <20120114204127.GA4100@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	<linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	<ken@codelabs.ch>,
	"Steffen Klassert" <steffen.klassert@secunet.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, <security@kernel.org>
To: "Alexey Dobriyan" <adobriyan@gmail.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120114204127.GA4100@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Doesn't this badly overflow W[] ..
 
> +#define SHA512_0_15(i, a, b, c, d, e, f, g, h) \
> +	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
...
> +	for (i = 0; i < 16; i += 8) {
...
> +		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
> +	}

	David

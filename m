From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Tue, 9 Dec 2014 22:24:23 +0800
Message-ID: <20141209142423.GB9745@gondor.apana.org.au>
References: <20141207125157.GA9745@gondor.apana.org.au>
 <20141207132305.24691.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dborkman@redhat.com,
	hannes@stressinduktion.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, tytso@mit.edu
To: George Spelvin <linux@horizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141207132305.24691.qmail@ns.horizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 07, 2014 at 08:23:05AM -0500, George Spelvin wrote:
>
> Okay, I'm confused.  *What* scheme?  The arch_fast_hash interface doesn't
> have any provision for a secret.  Because there's no point to having one;

It does actually, in the form of the seed parameter.  That's why
it's so bad: it pretends to be a semi-secure hash function that
people will use in hash tables.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

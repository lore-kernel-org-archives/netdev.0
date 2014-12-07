From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Sun, 7 Dec 2014 20:51:57 +0800
Message-ID: <20141207125157.GA9745@gondor.apana.org.au>
References: <20141207092828.GA8623@gondor.apana.org.au>
 <20141207100252.6707.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch, "David S. Miller" <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:33372 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbaLGMwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 07:52:09 -0500
Content-Disposition: inline
In-Reply-To: <20141207100252.6707.qmail@ns.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 07, 2014 at 05:02:52AM -0500, George Spelvin wrote:
>
> How does this implicate the low bits specifically?

If you can easily deduce the pre-images that make the last bit
of the hash even or odd, then you've just cut your search space
for collisions by half.  The real killer is that you can do this
without knowing what the secret is.

Our entire scheme is dependent on using the secret to defeat
would-be attackers.  If CRC does not make effective use of the
secret, then we're essentially naked against attackers.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

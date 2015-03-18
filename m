From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Wed, 18 Mar 2015 20:55:16 +1100
Message-ID: <20150318095516.GA22634@gondor.apana.org.au>
References: <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
 <20150317124012.GH11089@casper.infradead.org>
 <20150317215638.GA16776@gondor.apana.org.au>
 <20150318095102.GL17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "'tgraf@suug.ch'" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47843 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755AbbCRJzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:55:33 -0400
Content-Disposition: inline
In-Reply-To: <20150318095102.GL17829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2015 at 09:51:02AM +0000, 'tgraf@suug.ch' wrote:
> 
> I'm running it like this:
> for i in $(seq 1 27); do \
> echo $i: && ./jhash $((2**$i)) | uniq -D | uniq -c \

uniq -D doesn't do what you think it does:

$ { echo a; echo b; echo a; } | uniq -D
$

So you should use sort | uniq -c

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 22:25:23 +1100
Message-ID: <20150317112523.GB11671@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02510@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50931 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbbCQLZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 07:25:44 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB02510@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 11:22:44AM +0000, David Laight wrote:
>
> But won't the rehashed table be just as likely to have a long list?
> So you are likely to get an immediate rehash?

Not if the threshold is set to a value that should never be hit
at 100% utilisation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

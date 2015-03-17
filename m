From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 22:27:26 +1100
Message-ID: <20150317112726.GC11671@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "tgraf@suug.ch" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50945 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbCQL1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 07:27:47 -0400
Content-Disposition: inline
In-Reply-To: <20150317112203.GG11089@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 11:22:03AM +0000, tgraf@suug.ch wrote:
>
> Not sure I understand the downside of a bucket length based grow
> decision with optional forced rehashing plus synchroneous table
> realloc if we hit a 2nd watermark as you proposed earlier. Shouldn't
> we consider deterministic lookup and insert behaviour more important
> than overall table utilization? Given the rehashing, the grow decision
> should not be attackable.

Do you really want to double the table size when 0.1% of the buckets
have a chain length > 4 but still < 16?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

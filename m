From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 23:52:17 +1100
Message-ID: <20090107125217.GA26235@gondor.apana.org.au>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47244 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756733AbZAGMwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:52:35 -0500
Content-Disposition: inline
In-Reply-To: <20090107124946.GA9677@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 12:49:46PM +0000, Jarek Poplawski wrote:
> 
> Hmm... in any case: take 3

Yes this should fix the corruption but it kind of defeats the
purpose of splice by copying the data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

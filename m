From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 13:02:45 +0000
Message-ID: <20090107130245.GC9677@ff.dom.local>
References: <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local> <20090107125217.GA26235@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:48536 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbZAGNCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 08:02:55 -0500
Content-Disposition: inline
In-Reply-To: <20090107125217.GA26235@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 11:52:17PM +1100, Herbert Xu wrote:
> On Wed, Jan 07, 2009 at 12:49:46PM +0000, Jarek Poplawski wrote:
> > 
> > Hmm... in any case: take 3
> 
> Yes this should fix the corruption but it kind of defeats the
> purpose of splice by copying the data.
> 

Hmm.. Again - the main point of this patch was a proof of concept...
If the bug is really here it could be optimized (e.g. done only for
sendmesage) or fixed another way.

Jarek P.

From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 14:00:31 +0100
Message-ID: <20090107130031.GD6307@1wt.eu>
References: <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local> <20090107125217.GA26235@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757521AbZAGNEU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090107125217.GA26235@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 07, 2009 at 11:52:17PM +1100, Herbert Xu wrote:
> On Wed, Jan 07, 2009 at 12:49:46PM +0000, Jarek Poplawski wrote:
> > 
> > Hmm... in any case: take 3
> 
> Yes this should fix the corruption but it kind of defeats the
> purpose of splice by copying the data.

that's what I was initially wondering about, but it looks like only linear
data is copied. Will that cause too much a overhead ? (I don't like copying
at all anyway, but if it can help us find the cause, I'll happily test it).

BTW, Jarek, don't be sorry, I *am* expecting to crash my laptop a number of
times before ensuring the bug is fixed. I just don't want to lose my data.

Cheers,
Willy

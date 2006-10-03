From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Tue, 3 Oct 2006 12:30:30 +0200
Message-ID: <20061003103029.GC7778@kernel.dk>
References: <20061002102447.GA2936@ff.dom.local> <200610021649.39580.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([62.242.22.158]:33811 "EHLO kernel.dk")
	by vger.kernel.org with ESMTP id S1030210AbWJCKa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 06:30:57 -0400
To: Ismail Donmez <ismail@pardus.org.tr>
Content-Disposition: inline
In-Reply-To: <200610021649.39580.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02 2006, Ismail Donmez wrote:
> 02 Eki 2006 Pts 13:24 tarihinde, Jarek Poplawski ??unlar?? yazm????t??: 
> > On 30-09-2006 21:23, Ismail Donmez wrote:
> > > Hi,
> > >
> > > With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE
> > > changed behaviour so it returns false when the node is empty as expected.
> >
> > ...
> >
> > > -	if (!RB_EMPTY_NODE(rb)) {
> > > +	if (RB_EMPTY_NODE(rb)) {
> >
> > Maybe you have some kind of agreement with Jens Axboe but I
> > can't understand current way of kernel cooperation:
> > he changes some global behavior to the opposite and fixes
> > his code in three places but can't fix it in the fourth place
> > where it's used? Isn't it both trivial and automatic kind
> > of patch?
> 
> I don't know if Jens will going to fix other occurrences but the
> sch_htb.c fix was recent and Jens'  commit got my attention hence the
> patch.

Send me a patch and I'll review / integrate it. Most of the rbtree
mixups stem from the fact that the first color change was incomplete.

-- 
Jens Axboe


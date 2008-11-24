From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: gen_estimator: Fix gen_kill_estimator() lookups
Date: Mon, 24 Nov 2008 13:37:24 +0000
Message-ID: <20081124133724.GC16755@ff.dom.local>
References: <20081124120404.GA16413@ff.dom.local> <1227532725.22481.14.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:14774 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbYKXNha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:37:30 -0500
Received: by ug-out-1314.google.com with SMTP id 39so740253ugf.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 05:37:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1227532725.22481.14.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 08:18:45AM -0500, jamal wrote:
> On Mon, 2008-11-24 at 12:04 +0000, Jarek Poplawski wrote:
> > gen_kill_estimator() linear lists lookups are very slow, and e.g. while
> > deleting a large number of HTB classes soft lockups were reported. Here
> > is another try to fix this problem: this time internally, with rbtree,
> > so similarly to Jamal's hashing idea IIRC. (Looking for next hits could
> > be still optimized, but it's really fast as it is.)
> 
> Certainly a big improvement. Compared to hashing i suggested:
> the deletion speed is probably equal or better than using a hash.
> I think a hash would have performed better in the case of addition
> than the rb tree; but you primarily concerned about deletion, so this
> good.

I first thought about a hash, but alas Patrick's solution is sched
only... Anyway, I din't see too much overhead in memory use, and no
diffrence in addition times (without batching).

> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 

Thanks,
Jarek P.

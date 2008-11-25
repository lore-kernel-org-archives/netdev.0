From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: gen_estimator: Fix gen_kill_estimator() lookups
Date: Tue, 25 Nov 2008 07:52:59 +0000
Message-ID: <20081125075259.GA4265@ff.dom.local>
References: <20081124120404.GA16413@ff.dom.local> <1227532725.22481.14.camel@dogo.mojatatu.com> <20081124133724.GC16755@ff.dom.local> <1227538858.22481.29.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:65211 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbYKYHxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 02:53:06 -0500
Received: by ug-out-1314.google.com with SMTP id 39so985894ugf.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 23:53:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1227538858.22481.29.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 10:00:58AM -0500, jamal wrote:
> On Mon, 2008-11-24 at 13:37 +0000, Jarek Poplawski wrote:
> 
> > I first thought about a hash, but alas Patrick's solution is sched
> > only... Anyway, I din't see too much overhead in memory use, and no
> > diffrence in addition times (without batching).
> 
> Showing numbers in a commit for perf improvement IMO is always a good
> thing.

Sure, but alas I'm not a perf guy...

> BTW, I dont think it would make a noticeable difference (batching
> notwithstanding) in addition or even deletion unless you have quiet a
> few with the same estimate sampling time loaded.

My very unprofessional tests gave approximately 319s vs. 0.34s with:
"time tc qdisc del dev lo root" for 65535 htb classes, and as you
predicted (and I was surprised) no noticeable difference in addition
times with or without batching.
 
Cheers,
Jarek P.

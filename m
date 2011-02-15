From: David Rientjes <rientjes@google.com>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Tue, 15 Feb 2011 14:21:11 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1102151403170.10742@chino.kir.corp.google.com>
References: <bug-27212-10286@https.bugzilla.kernel.org/> <20110120122549.85863a84.akpm@linux-foundation.org> <1295556085.2613.22.camel@edumazet-laptop> <4D393A99.9060104@kernel.org> <1297704922.2996.60.camel@edumazet-laptop>
 <AANLkTinKTdeO5mnE38n==aZMz5P1XKKM+kykhoBu0=9k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Changli Gao <xiaosuo@gmail.com>,
	Vegard Nossum <vegardno@ifi.uio.no>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Lameter <cl@linux.com>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:44461 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756209Ab1BOWVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 17:21:19 -0500
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p1FMLH5f031073
	for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 14:21:17 -0800
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq13.eem.corp.google.com with ESMTP id p1FMKovQ016183
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 14:21:16 -0800
Received: by pxi7 with SMTP id 7so98027pxi.36
        for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 14:21:15 -0800 (PST)
In-Reply-To: <AANLkTinKTdeO5mnE38n==aZMz5P1XKKM+kykhoBu0=9k@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Feb 2011, Pekka Enberg wrote:

> > [PATCH] slub: fix kmemcheck calls to match ksize() hints
> >
> > Recent use of ksize() in network stack (commit ca44ac38 : net: don't
> > reallocate skb->head unless the current one hasn't the needed extra size
> > or is shared) triggers kmemcheck warnings, because ksize() can return
> > more space than kmemcheck is aware of.
> >
> > Pekka Enberg noticed SLAB+kmemcheck is doing the right thing, while SLUB
> > +kmemcheck doesnt.
> >
> > Bugzilla reference #27212
> >
> > Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> > Suggested-by: Pekka Enberg <penberg@kernel.org>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: David Miller <davem@davemloft.net>
> > CC: Changli Gao <xiaosuo@gmail.com>
> > CC: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

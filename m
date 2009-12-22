From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Tue, 22 Dec 2009 16:26:59 +0100
Message-ID: <20091222152658.GA16043@core.hellgate.ch>
References: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de>
 <20091222123211.GA8546@ff.dom.local>
 <20091222132107.GA9060@ff.dom.local>
 <20091222133817.GA9208@ff.dom.local>
 <20091222150045.GA5355@wrars-comp.wrarsdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Christian Kujau <lists@nerdbynature.de>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Andrey Rahmatullin <wrar@altlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail15.bluewin.ch ([195.186.18.63]:24091 "EHLO
	mail15.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbZLVP05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 10:26:57 -0500
Content-Disposition: inline
In-Reply-To: <20091222150045.GA5355@wrars-comp.wrarsdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2009 20:00:45 +0500, Andrey Rahmatullin wrote:
> On Tue, Dec 22, 2009 at 01:38:17PM +0000, Jarek Poplawski wrote:
> > > > It looks like napi_disable() should be illegal in ndo_tx_timeout().
> > > > Here is a patch which moves most of the timeout work to a workqueue,
> > > > similarly to tg3 etc. It should prevent at least one of reported
> > > > bugs. Alas I can't even check-compile it at the moment, so let me
> > > > know on any problems.
> > > It seems I needlessly changed locking btw, so here it is again.
> > Hmm... On the other hand, it definitely needs at least _bh now...
> I've tried this patch. There are lots of "Transmit timed out", but no
> crashes.

ACK. Looks like you guys tracked down the crashing and fixed it (thanks!).
I suspect we shouldn't have to reset due to timeouts that often, but that's
another story.

Roger

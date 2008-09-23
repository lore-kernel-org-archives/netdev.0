From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 07:49:29 -0400
Message-ID: <20080923114927.GA2506@infradead.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080922.191826.16007223.davem@davemloft.net> <20080923022731.GE25711@one.firstfloor.org> <20080923063407.GB23815@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, ak@linux.intel.com
To: Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47456 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbYIWLtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 07:49:47 -0400
Content-Disposition: inline
In-Reply-To: <20080923063407.GB23815@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 08:34:07AM +0200, Karsten Keil wrote:
> No really needed, normally the timers deleted long time before running out
> or never so it should never see such a race, maybe if the application is
> aborted and cleanup all timers this could happen but also this should be no
> normal case, since usually you do not kill a PBX if any connections are
> active.
> Yes it could be used to do some deny on service kind of attack, so it should
> be fixed at all.

All these timers are completely user controller and non-prviliegued.  So
this _is_ a serious issue.  In fact I think we should just rip out this
whole module, it's a really useless duplicate timer interface.

Gotta love merging unreviewed code.


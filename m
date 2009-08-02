From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] mISDN: Fix handling of receive buffer size in L1oIP
Date: Sun, 02 Aug 2009 13:02:25 -0700 (PDT)
Message-ID: <20090802.130225.53875200.davem@davemloft.net>
References: <cover.1248781021.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	andreas@eversberg.eu, acme@redhat.com
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753058AbZHBUCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 16:02:17 -0400
In-Reply-To: <cover.1248781021.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Tue, 28 Jul 2009 13:37:01 +0200

> This patch fix a regression introduced in 2.6.31 with the commit
> 8c90e11e3543d7de612194a042a148caeaab5f1d "mISDN: Use kernel_{send,recv}msg instead of open coding".
> 
> Linus: you can pull the fix from
> git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next for_linus
> 
> David for net-next-2.6 you can get it from:
> git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next for_david

Karsten, please don't send fix incusion requests like this.  Either
send them via me always, or bypass me and go straight to Linus
always.

Asking two people to pull the fix in via two different means only
will make for confusion.

If it's a fix, get it into net-2.6 via me, otherwise submit it to
net-next-2.6 if it is not an important fix.  Sending it to Linus
and my net-next-2.6 at the same time makes %100 no sense.  One
tree is for fixes, and the other is for new development.

If you're worried about fixes propagating and merging properly,
I take care of that completely.  When a fix gets into net-2.6
eventually I will merge net-2.6 into net-next-2.6 and that's how
it will show up there.  If there is a dependency on new work that
this fix creates, tell me, and I'll do the merge more quickly
for you.

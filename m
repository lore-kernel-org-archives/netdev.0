From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 17:32:56 -0700 (PDT)
Message-ID: <20060808.173256.64863348.davem@davemloft.net>
References: <200608090123.01123.ak@suse.de>
	<20060808.171152.58440635.davem@davemloft.net>
	<200608090224.04158.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, kuznet@ms2.inr.ac.ru, dev@sw.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23728
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030261AbWHIAdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:33:16 -0400
To: ak@suse.de
In-Reply-To: <200608090224.04158.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Wed, 9 Aug 2006 02:24:04 +0200

> Yes, but even with dynamic growth you still need some upper boundary 
> (otherwise a DOS could eat all your memory). And it would need
> to be figured out what it is.

Absolutely.  Otherwise the GC'ing of the routing cache would
break horribly.

> BTW does dynamic shrink after a load spike make sense too?

I'm not sure about that bit yet.

> Or do some cheesy default and document the options to change
> it clearly and wait for feedback from users on what works for
> them?

I think this makes sense.  An initial upper limit of 1 million hash
table slots seems reasonable at first.  That's 8MB on a 64-bit
machine.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Sun, 06 Aug 2006 23:18:46 -0700 (PDT)
Message-ID: <20060806.231846.71090637.davem@davemloft.net>
References: <20060803.144845.66061203.davem@davemloft.net>
	<20060803235326.GC7894@thunk.org>
	<Pine.LNX.4.58.0608070124340.15870@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53425
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751102AbWHGGSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 02:18:47 -0400
To: rostedt@goodmis.org
In-Reply-To: <Pine.LNX.4.58.0608070124340.15870@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 7 Aug 2006 01:34:56 -0400 (EDT)

> My suggestion would be to separate that tg3_timer into 4 different
> timers, which is what it actually looks like.

Timers have non-trivial cost.  It's cheaper to have one and
vector off to the necessary operations each tick internalls.

That's why it's implemented as one timer.

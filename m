From: "Bradley M. Kuhn" <bkuhn@ebb.org>
Subject: Re: [Bugme-new] [Bug 10682] New: (net 8139too) dual ethernet   system, any reasonable network causes: NETDEV WATCHDOG: ethN: transmit   timed out
Date: Tue, 13 May 2008 10:35:26 -0400
Message-ID: <87y76enufl.fsf@hughes.sflc-vpn>
References: <bug-10682-10286@http.bugzilla.kernel.org/>
	<20080511211055.af2595e9.akpm@linux-foundation.org>
	<20080512214014.GB27236@ebb.org>
	<20080512151142.067b98d2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sflc.info ([216.27.154.199]:53408 "EHLO mail.sflc.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677AbYEMPTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 11:19:48 -0400
In-Reply-To: <20080512151142.067b98d2.akpm@linux-foundation.org> (Andrew Morton's message of "Mon\, 12 May 2008 15\:11\:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex (quoted below) must have seen my bug ticket regarding the 8319too
WATCHDOG bug and replied to me privately.  I include his message below
primarily for posterity on the bug ticket and mailing list archives.  He's
confirming 2.6.23 fails in the same way as well on this particular box
with the two 8139too cards in it.

I expect to try the older kernel versions Andrew suggested in the next few
days and will report back when I have.

Meanwhile, I have vague and more-or-less unfounded theory that this bug is
specific to having two of the same style card in the same box.  Would it
be useful, assuming that I can't make an older kernel work, to try seeing
if I can physically unwire one of the ethernet cards to see if the problem
occurs with only one card wired up?  (This may be undoable without
breaking something on this tiny box, but I'm willing to have a go if folks
think it might help.)
#########################################################################
Date: Tue, 13 May 2008 16:40:46 +0800
To: bkuhn@ebb.org
Subject: Re: (net 8139too) dual ethernet system, any reasonable network causes: NETDEV
From: "Alex REDACTED" <redacted@example.com>

We're using an ebox 4852/4853 with debian linux kernel 2.6.23.

Today during testing, we found the exact problem that you're reporting -  
NETDEV WATCHDOG timeouts when any reasonable network load is placed on
routing between the ethernet ports.

We're using the 8139too driver too, version 0.9.28.

No solutions yet, we will probably look into it as time permits.

Just thought you might appreciate another kernel version data point.

Cheers,
-- 
Alex.
#########################################################################
-- 

   -- bkuhn

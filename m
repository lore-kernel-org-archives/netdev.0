From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 00:54:08 +0200
Message-ID: <87k5e2qdbj.fsf@basil.nowhere.org>
References: <bug-459782-176318@bugzilla.redhat.com>
	<200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com>
	<20080826163719.GA25066@redhat.com> <87zlmyr5nz.fsf@basil.nowhere.org>
	<Pine.LNX.4.64.0808271427040.3610@t2.domain.actdsltmp>
	<20080827214700.GB26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52171 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbYH0WyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:54:15 -0400
In-Reply-To: <20080827214700.GB26610@one.firstfloor.org> (Andi Kleen's message of "Wed, 27 Aug 2008 23:47:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 
>> Umm, 0.4 to 0.8 seconds is on average _slower_ than 0.44 seconds.  Did you
>> mean .04 to .08?
>
> Yes noticed that too -- i think it must have been .04-.08 and the zeros
> got lost somewhere. I remember that it was significantly faster. It's really 
> a benchmark how fast an read lock aquire/release is, but even on 
> the best systems it's quite slow compared to lockless code.

FWIW I redid the benchmarks now and it's 0.046s (without) to 0.005s (with 
patch) on a different 2GB Core2 system with nearly empty hash table.

-Andi

-- 
ak@linux.intel.com

From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 23:47:00 +0200
Message-ID: <20080827214700.GB26610@one.firstfloor.org>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com> <87zlmyr5nz.fsf@basil.nowhere.org> <Pine.LNX.4.64.0808271427040.3610@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Dave Jones <davej@redhat.com>,
	netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40414 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbYH0Vo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 17:44:28 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808271427040.3610@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 02:29:18PM -0700, Trent Piepho wrote:
> On Wed, 27 Aug 2008, Andi Kleen wrote:
> > On a 2GB Core2 system here I see a time cat /proc/net/tcp > /dev/null
> > constently dropping from 0.44s to 0.4-0.8s system time with this change.
> > This is with mostly empty hash tables.
> 
> Umm, 0.4 to 0.8 seconds is on average _slower_ than 0.44 seconds.  Did you
> mean .04 to .08?

Yes noticed that too -- i think it must have been .04-.08 and the zeros
got lost somewhere. I remember that it was significantly faster. It's really 
a benchmark how fast an read lock aquire/release is, but even on 
the best systems it's quite slow compared to lockless code.

-Andi

-- 
ak@linux.intel.com

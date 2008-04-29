From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Tue, 29 Apr 2008 17:14:03 +0200
Message-ID: <20080429151403.GA19410@elte.hu>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> <20080429102107.GH23198@elte.hu> <D5C1322C3E673F459512FB59E0DDC32904F9F13E@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:36895 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbYD2POX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:14:23 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32904F9F13E@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:

> > * PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:
> > 
> > > This bug was introduced in the 2.6.24 i386/x86_64 tree merge, [...]
> > 
> > that's wrong, that code was there in v2.6.23 too - and it wasnt 
> > touched in the unification. Why do you think it was introduced in 
> > the i386/x86_64 tree merge?
> 
> 2.6.23.17 didn't have the used_vectors bitmap.  The first time I could 
> find it used was in 2.6.24.  Where was the code existing in 2.6.23?  
> The addition may have not been part of the merge, but it was 
> definitely introduced in the same timeframe, meaning the 2.6.24 
> release timeframe.

that change came in via lguest (commit dbeb2be2), not the 32-bit/64-bit 
x86 unification. Lguest is a new feature in 2.6.24 and this side-effect 
of it was not known until you fixed it - thanks for that!

So i was just splitting hairs over your statement that it was due to the 
unification :-)

	Ingo

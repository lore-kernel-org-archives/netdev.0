From: Dave Jones <davej@redhat.com>
Subject: Re: sch_generic warn_on (timed out)
Date: Thu, 21 Jul 2011 14:56:19 -0400
Message-ID: <20110721185619.GL23856@redhat.com>
References: <20110711204834.GA4950@redhat.com>
 <alpine.WNT.2.00.1107200931080.1084@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212Ab1GUS4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 14:56:22 -0400
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1107200931080.1084@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 09:38:32AM -0700, Brandeburg, Jesse wrote:

 > it used to just be a KERN_ERR printk, then it changed it to be a WARN_ONCE 
 > in order to trigger kerneloops reports so we knew how many people were 
 > getting tx hangs from their hardware.

That explains the uptick in reports we've got, as most of them
seem to be coming in through abrt (Fedora's kerneloops-like thing). 

 > If this is happening more frequently on F15 than F14 across multiple 
 > pieces of hardware, it may indicate that a kernel/stack change is starting 
 > to (ab)use a changed working model that is causing an issue, or that there 
 > is an actual kernel issue with locks or interrupts or tx completions that 
 > is causing an excessive delay in completion of transmits.
 > 
 > Dave can you query for F14 reports and/or isolate what kernel this started 
 > with?

Unfortunatly, F14 lagged behind rebasing for unrelated reasons, and is still stuck
on 2.6.35, so we've got quite a delta between that and f15 right now.

A quick search of the F14 bugs didn't show up any similar bugs, but due to the 4
versions we jumped, that's probably not too helpful, as it's probably still
just a printk in that old codebase.

We have plans in progress to rebase both releases to something more current,
so I'll keep an eye on this to see if it gets worse/better.

thanks,

        Dave


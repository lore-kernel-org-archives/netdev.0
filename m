From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Fri, 3 Jul 2009 06:12:13 +0000
Message-ID: <20090703061213.GA4847@ff.dom.local>
References: <200907030331.32531.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f207.google.com ([209.85.218.207]:39852 "EHLO
	mail-bw0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbZGCGMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 02:12:16 -0400
Content-Disposition: inline
In-Reply-To: <200907030331.32531.andres@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 03:31:31AM +0200, Andres Freund wrote:
...
> Ok. I finally see the light. I bisected the issue down to
> eea08f32adb3f97553d49a4f79a119833036000a :  timers: Logic to move non
> pinned timers
>
> Disabling timer migration like provided in the earlier commit stops the 
> issue from occuring.
>
> That it is related to timers is sensible in the light of my findings, 
> that I could trigger the issue only when using delay in netem - that is 
> the codepath using qdisc_watchdog...

Andres, thanks for your work and time. It saved me a lot of searching,
because I wasn't able to trigger this on my old box.

Jarek P.

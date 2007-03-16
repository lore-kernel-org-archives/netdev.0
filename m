From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 00/10]: ktime clocksource + hrtimer
Date: Fri, 16 Mar 2007 02:35:10 -0700 (PDT)
Message-ID: <20070316.023510.41635847.davem@davemloft.net>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933238AbXCPJfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 05:35:12 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 16 Mar 2007 06:30:48 +0100 (MET)

> These patches convert the packet schedulers to use ktime as only clock
> source and kill off the manual clock source selection. Additionally all
> packet schedulers are converted to use hrtimer-based watchdogs, greatly
> increasing scheduling precision.
> 
> I've tested HFSC, HTB, TBF and netem. CBQ is untested since I never
> managed to get it running properly even without these patches.
> 
> I have a number of follow-up cleanup patches that get rid of most of
> the remaining PSCHED_* macros, I'll send them once these patches have
> been merged.
> 
> Please apply, thanks.

All 11 patches applied and pushed out, very very nice work
Patrick!

It would be nice to figure out why CBQ isn't working for
you, I know at least some folks have used it successfully
at some point.

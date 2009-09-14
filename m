From: Tejun Heo <tj@kernel.org>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Mon, 14 Sep 2009 18:40:11 +0900
Message-ID: <4AAE0F7B.5050203@kernel.org>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com> <200909120623.49764.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:46619 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972AbZINJkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 05:40:21 -0400
In-Reply-To: <200909120623.49764.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frans Pop wrote:
> Jesse Brandeburg wrote:
>> I've bisected, here is my bisect log, problem is that the commit
>> identified is a merge commit, and *I don't know what to revert to test*.
>> It appears the parent of the merge:
>> 6e15cf04860074ad032e88c306bea656bbdd0f22 is marked good, but looks to be
>> in a possibly related area to the panic.
> 
> That merge does contain quite a few merge fixups, so it's quite possible 
> one of them is the cause of the failure.
> Maybe the simplest way to verify that is to compile both parents of the 
> merge to doublecheck that they work OK. Then, if a compile of the merge 
> itself is bad, the problem really is in the merge commit itself.
> 
> That commit is the "percpu" merge, so I've added Tejun (author of most of 
> that branch) and Ingo (merger) in CC.

Sorry, the oops doesn't ring a bell, well, not yet at least.  It would
be great if the bisection can be narrowed down more.

-- 
tejun

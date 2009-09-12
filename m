From: Frans Pop <elendil@planet.nl>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Sat, 12 Sep 2009 06:23:47 +0200
Message-ID: <200909120623.49764.elendil@planet.nl>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752808AbZILEXu@vger.kernel.org>
In-reply-To: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> I've bisected, here is my bisect log, problem is that the commit
> identified is a merge commit, and *I don't know what to revert to test*.
> It appears the parent of the merge:
> 6e15cf04860074ad032e88c306bea656bbdd0f22 is marked good, but looks to be
> in a possibly related area to the panic.

That merge does contain quite a few merge fixups, so it's quite possible 
one of them is the cause of the failure.
Maybe the simplest way to verify that is to compile both parents of the 
merge to doublecheck that they work OK. Then, if a compile of the merge 
itself is bad, the problem really is in the merge commit itself.

That commit is the "percpu" merge, so I've added Tejun (author of most of 
that branch) and Ingo (merger) in CC.

Hope that helps.

Cheers,
FJP

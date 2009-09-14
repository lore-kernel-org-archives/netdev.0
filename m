From: Tejun Heo <tj@kernel.org>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Mon, 14 Sep 2009 18:43:58 +0900
Message-ID: <4AAE105E.1080005@kernel.org>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com> <200909120623.49764.elendil@planet.nl> <4AAE0F7B.5050203@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755338AbZINJoS@vger.kernel.org>
In-Reply-To: <4AAE0F7B.5050203@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo wrote:
> Frans Pop wrote:
>> Jesse Brandeburg wrote:
>>> I've bisected, here is my bisect log, problem is that the commit
>>> identified is a merge commit, and *I don't know what to revert to test*.
>>> It appears the parent of the merge:
>>> 6e15cf04860074ad032e88c306bea656bbdd0f22 is marked good, but looks to be
>>> in a possibly related area to the panic.
>> That merge does contain quite a few merge fixups, so it's quite possible 
>> one of them is the cause of the failure.
>> Maybe the simplest way to verify that is to compile both parents of the 
>> merge to doublecheck that they work OK. Then, if a compile of the merge 
>> itself is bad, the problem really is in the merge commit itself.
>>
>> That commit is the "percpu" merge, so I've added Tejun (author of most of 
>> that branch) and Ingo (merger) in CC.
> 
> Sorry, the oops doesn't ring a bell, well, not yet at least.  It would
> be great if the bisection can be narrowed down more.

Also, building w/ debug option on, capturing more oops traces and
pasting gdb output of l *<oops address> might shed some more light.

Thanks.

-- 
tejun

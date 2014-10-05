From: Joe Lawrence <joe.lawrence@stratus.com>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Sun, 5 Oct 2014 08:53:08 -0400
Message-ID: <54313F34.8090801@stratus.com>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com> <20140929160601.GD15925@htj.dyndns.org> <20141002064308.GN5015@linux.vnet.ibm.com> <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com> <20141004083732.GG5015@linux.vnet.ibm.com> <20141005021325.GB8549@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Tejun Heo <tj@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o142.mxlogic.net ([208.65.145.65]:50200 "EHLO
	p01c12o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaJEMxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 08:53:24 -0400
In-Reply-To: <20141005021325.GB8549@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2014 10:13 PM, Tejun Heo wrote:
> Hello,
> 
> On Sat, Oct 04, 2014 at 01:37:32AM -0700, Paul E. McKenney wrote:
>> FWIW, there is a cond_resched_rcu_qs() that should be going into the next
>> merge window that could be used in place of the above two lines.  This is
>> commit bde6c3aa9930 in -tip.
> 
> That sounds even better.
> 
> Joe, can you please send a patch with proper SOB and description?
> 
> Thanks.

New patch tested and posted on lkml w/everyone CC'd.

I wasn't sure if cond_resched_rcu_qs will be backported, so how should
-stable handle this condition?

Regards,

-- Joe

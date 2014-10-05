From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Sun, 5 Oct 2014 07:08:55 -0700
Message-ID: <20141005140855.GO5015@linux.vnet.ibm.com>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
 <20140929160601.GD15925@htj.dyndns.org>
 <20141002064308.GN5015@linux.vnet.ibm.com>
 <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com>
 <20141004083732.GG5015@linux.vnet.ibm.com>
 <20141005021325.GB8549@htj.dyndns.org>
 <54313F34.8090801@stratus.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>
To: Joe Lawrence <joe.lawrence@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:40030 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaJEOJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 10:09:00 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 5 Oct 2014 08:09:00 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1D6E919D803E
	for <netdev@vger.kernel.org>; Sun,  5 Oct 2014 07:57:42 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s95C4iM457278664
	for <netdev@vger.kernel.org>; Sun, 5 Oct 2014 14:04:44 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s95EDXgl002877
	for <netdev@vger.kernel.org>; Sun, 5 Oct 2014 08:13:34 -0600
Content-Disposition: inline
In-Reply-To: <54313F34.8090801@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2014 at 08:53:08AM -0400, Joe Lawrence wrote:
> On 10/04/2014 10:13 PM, Tejun Heo wrote:
> > Hello,
> > 
> > On Sat, Oct 04, 2014 at 01:37:32AM -0700, Paul E. McKenney wrote:
> >> FWIW, there is a cond_resched_rcu_qs() that should be going into the next
> >> merge window that could be used in place of the above two lines.  This is
> >> commit bde6c3aa9930 in -tip.
> > 
> > That sounds even better.
> > 
> > Joe, can you please send a patch with proper SOB and description?
> > 
> > Thanks.
> 
> New patch tested and posted on lkml w/everyone CC'd.
> 
> I wasn't sure if cond_resched_rcu_qs will be backported, so how should
> -stable handle this condition?

If it is needed to backport a fix, it can of course be backported.
The various -stable maintainers also have the option of avoiding
the need for a backport by expanding it inline.  I am happy to let
them choose.  ;-)

							Thanx, Paul

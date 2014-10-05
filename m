From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Sun, 5 Oct 2014 12:11:13 -0400
Message-ID: <20141005161113.GA22223@mtj.dyndns.org>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
 <20140929160601.GD15925@htj.dyndns.org>
 <20141002064308.GN5015@linux.vnet.ibm.com>
 <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com>
 <20141004083732.GG5015@linux.vnet.ibm.com>
 <20141005021325.GB8549@htj.dyndns.org>
 <54313F34.8090801@stratus.com>
 <20141005140855.GO5015@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Lawrence <joe.lawrence@stratus.com>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:50891 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbaJEQLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 12:11:16 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so2777282qgd.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 09:11:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141005140855.GO5015@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Paul, Joe.

On Sun, Oct 05, 2014 at 07:08:55AM -0700, Paul E. McKenney wrote:
> > I wasn't sure if cond_resched_rcu_qs will be backported, so how should
> > -stable handle this condition?
> 
> If it is needed to backport a fix, it can of course be backported.
> The various -stable maintainers also have the option of avoiding
> the need for a backport by expanding it inline.  I am happy to let
> them choose.  ;-)

Let's go for separate cond_resched + rcu_qs calls first and then apply
a separate patch to use cond_resched_rcu_qs() so that the first one
can be marked for -stable.

Thanks.

-- 
tejun

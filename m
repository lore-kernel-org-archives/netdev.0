From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: meant hlist_* - Re: hash_list and rcu locking question
Date: Fri, 8 Aug 2008 15:21:17 -0700
Message-ID: <20080808222117.GL6760@linux.vnet.ibm.com>
References: <379e30200808061849w3a47f981s5ccde245059f595b@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	NetDev <netdev@vger.kernel.org>
To: Tobias Koeck <tobias.koeck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:53979 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbYHHWVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 18:21:24 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m78MLNYs007331
	for <netdev@vger.kernel.org>; Fri, 8 Aug 2008 18:21:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m78MLN9v183954
	for <netdev@vger.kernel.org>; Fri, 8 Aug 2008 16:21:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m78MLMeU004670
	for <netdev@vger.kernel.org>; Fri, 8 Aug 2008 16:21:23 -0600
Content-Disposition: inline
In-Reply-To: <379e30200808061849w3a47f981s5ccde245059f595b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 03:49:43AM +0200, Tobias Koeck wrote:
> I mean the rcu function for the hlist_{head,list} ....

There are some examples in http://lwn.net/Articles/262464/

This document notes that updates must be protected by some sort of
synchronization mechanism, for example, a lock.  RCU protects the
readers.

Additional information is available at http://lwn.net/Articles/263130/
and http://lwn.net/Articles/264090/

							Thanx, Paul

> Greetings
> t.
> 
> On Wed, Aug 6, 2008 at 10:54 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > Hi Tobias.
> >
> > On Wed, Aug 06, 2008 at 05:56:43PM +0200, Tobias Koeck (tobias.koeck@gmail.com) wrote:
> >> Are the hash_list rcu functions avoiding all locking problems (even
> >> the one with only one CPU)?
> >
> > What is hash list? hlist? Or list in a hash bucket?
> > Does include/linux/rculist.h contain needed bits?
> >
> >> Are there some abstract examples for the use of the hash_{head,list} structures?
> >
> > Sorry, my kernel source tree does not know what is 'hash_head'.
> > What data structure exactly do you mean?
> >
> > --
> >        Evgeniy Polyakov
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: xfrm_state locking regression...
Date: Fri, 12 Sep 2008 10:37:50 -0700
Message-ID: <20080912173750.GE6732@linux.vnet.ibm.com>
References: <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <20080911212459.GL6693@linux.vnet.ibm.com> <20080911.150006.53056393.davem@davemloft.net> <20080912160825.GA5690@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:33568 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbYILRh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 13:37:58 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8CHbpl1001814
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 13:37:51 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8CHbom3159306
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 11:37:51 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8CHbooM016948
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 11:37:50 -0600
Content-Disposition: inline
In-Reply-To: <20080912160825.GA5690@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 02:08:25AM +1000, Herbert Xu wrote:
> On Thu, Sep 11, 2008 at 03:00:06PM -0700, David Miller wrote:
> >
> > > There is only one reader at a time, right?  Otherwise, I don't see how
> > > the increments and reads of xfrm_state_walk_completed line up.
> > 
> > The RTNL semaphore is held across the modifications of the counters.
> 
> s/RTNL/xfrm_cfg_mutex/
> 
> but otherwise what Dave said :)

Thank you for the updated information, and I guess I don't feel quite
so bad about the false alarm.  ;-)

							Thanx, Paul

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: don't use INIT_RCU_HEAD
Date: Tue, 28 Oct 2008 09:05:48 -0700
Message-ID: <20081028160548.GE6779@linux.vnet.ibm.com>
References: <20081028133124.GA3006@x200.localdomain> <49072FC2.8030801@trash.net> <20081028154341.GA22583@x200.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:48265 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbYJ1QFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 12:05:50 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9SG2O1W024403
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 12:02:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SG5n2D131026
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 12:05:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SG5muQ016629
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 12:05:49 -0400
Content-Disposition: inline
In-Reply-To: <20081028154341.GA22583@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 06:43:41PM +0300, Alexey Dobriyan wrote:
> On Tue, Oct 28, 2008 at 04:29:06PM +0100, Patrick McHardy wrote:
> > Alexey Dobriyan wrote:
> >> call_rcu() will unconditionally rewrite RCU head anyway.
> >> Applies to 	struct neigh_parms
> >> 	struct neigh_table
> >> 	struct net
> >> 	struct cipso_v4_doi
> >> 	struct in_ifaddr
> >> 	struct in_device
> >> 	rt->u.dst
> >
> > It would probably make sense to get a statement from Paul
> > whether this might be required in the future, f.i. for some
> > debugging feature.
> 
> Let's cc him :-)

Can't say that I would be all that upset if INIT_RCU_HEAD() were to
simply vanish.  So I have no problem with it being removed from the
above functions.

Suppose I might as well find the original and Ack it.  ;-)

							Thanx, Paul

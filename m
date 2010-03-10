From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 13:25:56 -0800
Message-ID: <20100310212556.GD6255@linux.vnet.ibm.com>
References: <20100310131317.GA6267@linux.vnet.ibm.com> <20100310162658.GI6267@linux.vnet.ibm.com> <20100310.083547.213194954.davem@davemloft.net> <201003101856.53525.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:33931 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757290Ab0CJV0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 16:26:00 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2ALFZXk012901
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 16:15:35 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2ALPvoL163586
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 16:25:59 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2ALPupt019578
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 16:25:57 -0500
Content-Disposition: inline
In-Reply-To: <201003101856.53525.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 06:56:53PM +0100, Arnd Bergmann wrote:
> On Wednesday 10 March 2010, David Miller wrote:
> > From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> > Date: Wed, 10 Mar 2010 08:26:58 -0800
> >
> > > I have -tip commit a898def29e4119bc01ebe7ca97423181f4c0ea2d that
> > > converts some of the rcu_dereference()s in net/core/filter.c,
> > > net/core/dev.c, net/decnet/dn_route.c, net/packet/af_packet.c, and
> > > net/ipv4/route.c to rcu_dereference_bh().
> > > 
> > > How should we coordinate the removal of the rcu_read_lock() calls?
> > 
> > Paul if you want to do this via your tree, feel free.
> 
> My feeling is that this should be combined with the annotations I'm doing,
> annotating one subsystem at a time, and doing changes like these in the
> process. I'm still unsure what interface extensions there will have to
> be, but I guess we can the new interfaces as empty wrappers in the 2.6.34
> phase, and do all of the conversions where there are potential or real
> bugs.
> 
> All the other annotations can get queued in subsystem maintainer trees
> where it makes sense or get put in one tree for all the others, to be
> merged in after 2.6.34 is out.

Makes sense to me -- and thank you, Arnd, for taking this on!!!

							Thanx, Paul

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:38:40 -0700
Message-ID: <20081029183840.GD6732@linux.vnet.ibm.com>
References: <20081029163739.GB6732@linux.vnet.ibm.com> <49089E2D.8030907@cosmosbay.com> <20081029181114.GC6732@linux.vnet.ibm.com> <20081029.112956.43077212.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, minyard@acm.org, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:44445 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753054AbYJ2SjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 14:39:09 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9TIfilC006023
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:41:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TIcmsP116980
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:38:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TIceF9021988
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 14:38:47 -0400
Content-Disposition: inline
In-Reply-To: <20081029.112956.43077212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 11:29:56AM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Wed, 29 Oct 2008 11:11:14 -0700
> 
> > OK.  However, this reasoning assumes that a socket with a given
> > udp_hashfn() value will appear on one and only one list.  There are no
> > side lists for sockets in other states?  (listen, &c)
> 
> Nope, with UDP things are very simple, just one hash table.

Cool!  That does make things easier.  ;-)

							Thanx, Paul

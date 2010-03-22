From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 23:51:59 -0700
Message-ID: <20100322065159.GH2517@linux.vnet.ibm.com>
References: <20100321202525.GA966@basil.fritz.box>
 <20100321213703.GD2517@linux.vnet.ibm.com>
 <20100321.180140.45887114.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47423 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009Ab0CVGwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 02:52:03 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2M6bcUc015483
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 02:37:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2M6q2OD1818650
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 02:52:02 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2M6q1f1006404
	for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 02:52:02 -0400
Content-Disposition: inline
In-Reply-To: <20100321.180140.45887114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 06:01:40PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Sun, 21 Mar 2010 14:37:03 -0700
> 
> > net: suppress lockdep-RCU false positive in FIB trie.
> > 
> > Allow fib_find_node() to be called either under rcu_read_lock()
> > protection or with RTNL held.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> Thanks guys, I applied this copy and added Eric's signoff
> since the two patches were essentially identical :-)

Great minds thinking alike and all that.  ;-)

							Thanx, Paul

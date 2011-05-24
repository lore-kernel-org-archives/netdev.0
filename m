From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: use synchronize_rcu_expedited()
Date: Tue, 24 May 2011 12:56:44 -0700
Message-ID: <20110524195644.GI2266@linux.vnet.ibm.com>
References: <1306228052.3026.16.camel@edumazet-laptop>
 <20110524154445.GC2266@linux.vnet.ibm.com>
 <1306252364.3026.63.camel@edumazet-laptop>
 <20110524192451.GH2266@linux.vnet.ibm.com>
 <1306266285.3305.3.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:55410 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab1EXT4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 15:56:47 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4OJZj2Q020068
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 15:35:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4OJujZh108654
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 15:56:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4OJujM1024996
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 15:56:45 -0400
Content-Disposition: inline
In-Reply-To: <1306266285.3305.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 09:44:45PM +0200, Eric Dumazet wrote:
> Le mardi 24 mai 2011 =E0 12:24 -0700, Paul E. McKenney a =E9crit :
>=20
> > Might make sense, though most of the gains would need to come from
> > kicking the grace-period machinery hard in order to make it go fast=
er.
> >=20
> > Interesting -- I will give this some thought.
>=20
> I am working on a final step, using a workqueue so that the
> rcu_barrier() is not done under RTNL, so it wont be anymore a blockin=
g
> point to dismantle hundred of devices per second...

OK, I will keep rcu_barrier_expedited() on the "might be useful list",
but will keep to the current plan: finishing up rough edges on RCU
priority boosting, merging SRCU into TREE_RCU and TINY_RCU, and so fort=
h.

But let me know if you do need it.

							Thanx, Paul

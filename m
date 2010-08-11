From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 05:20:26 -0700
Message-ID: <20100811122026.GB2587@linux.vnet.ibm.com>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
 <20100810204358.GA1076@gondor.apana.org.au>
 <20100810211932.GG2379@linux.vnet.ibm.com>
 <20100810.163117.241919476.davem@davemloft.net>
 <20100811110330.GA6440@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:41036 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab0HKMUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:20:39 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7BC5tl0006867
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 08:05:55 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7BCKSKb378216
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 08:20:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7BCKR64008559
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 08:20:28 -0400
Content-Disposition: inline
In-Reply-To: <20100811110330.GA6440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 07:03:30AM -0400, Herbert Xu wrote:
> On Tue, Aug 10, 2010 at 04:31:17PM -0700, David Miller wrote:
> >
> > Linus's tree is fine for this.
> > 
> > But we need this fix for 2.6.35-stable too.  Herbert would
> > you object to putting John's more simple fix there?
> 
> To use rcu_read_lock safely we'd also need to add do synchronize_rcu
> in addition of synchronize_rcu_bh, right Paul?

That is true.

> Of course as we were doing this unsafely prior to my patch anyway
> I'm also fine with just reverting it.

That is true as well.

							Thanx, Paul

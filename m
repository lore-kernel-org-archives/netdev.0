From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Sun, 2 Jun 2013 20:42:04 -0700
Message-ID: <20130603034203.GB29614@linux.vnet.ibm.com>
References: <1369854387.5109.77.camel@edumazet-glaptop>
 <51A70CF4.1020807@yandex-team.ru>
 <1370215895.24311.93.camel@edumazet-glaptop>
 <20130602.195826.721294433730539253.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, klamm@yandex-team.ru, brouer@redhat.com,
	dipankar@in.ibm.com, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:39217 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab3FCDmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 23:42:17 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 2 Jun 2013 21:42:16 -0600
Content-Disposition: inline
In-Reply-To: <20130602.195826.721294433730539253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 02, 2013 at 07:58:26PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 02 Jun 2013 16:31:35 -0700
> 
> > On Thu, 2013-05-30 at 12:25 +0400, Roman Gushchin wrote:
> >> On 29.05.2013 23:06, Eric Dumazet wrote:
> >> > On Wed, 2013-05-29 at 14:09 +0400, Roman Gushchin wrote:
> >> >
> >> > True, these lookup functions are usually structured the same around the
> >> > hlist_nulls_for_each_entry_rcu() loop.
> >> >
> >> > A barrier() right before the loop seems to be a benefit, the size of
> >> > assembly code is reduced by 48 bytes.
> >> >
> >> > And its one of the documented way to handle this kind of problems
> >> > (Documentation/atomic_ops.txt line 114)
> >> >
> >> > I guess we should amend this documentation, eventually.
> >> >
> >> > Thanks, please add you "Signed-off-by" if you agree with the patch.
> >> >
> >> 
> >> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> >> 
> >> Many thanks to you, Paul E. McKenney and David Laight for your
> >> patches, help and participation in this discussion.
> > 
> > Thanks to you !
> > 
> > David, is there any problem with the patch ?
> > 
> > http://patchwork.ozlabs.org/patch/247360/ says "Not applicable", please
> > tell me what is needed to get it merged.
> 
> It's not a networking patch, it's a patch for generic RCU upstream.
> So it either goes through Paul McKenney, or directly via Linus on
> linux-kernel.

I would be happy to take it.

							Thanx, Paul

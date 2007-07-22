From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sun, 22 Jul 2007 01:24:42 -0700 (PDT)
Message-ID: <20070722.012442.57446124.davem@davemloft.net>
References: <20070721.205425.61337743.davem@davemloft.net>
	<20070722.001818.82052713.davem@davemloft.net>
	<1185090712.6344.72.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759950AbXGVIYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 04:24:43 -0400
In-Reply-To: <1185090712.6344.72.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sun, 22 Jul 2007 17:51:52 +1000

> On Sun, 2007-07-22 at 00:18 -0700, David Miller wrote:
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -220,7 +220,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
> >   *	Device drivers call our routines to queue packets here. We empty the
> >   *	queue in the local softnet handler.
> >   */
> > -DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
> > +
> > +DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL, };
> >  
> >  #ifdef CONFIG_SYSFS
> >  extern int netdev_sysfs_init(void);
> 
> ISTR that noone is using buggy compilers which required per-cpu
> initializations now, so this can simply be dropped.
> 
> (The new scheduler code doesn't initialize per-cpu, so if this is a
> problem it should be noticed).

Good catch and I've removed it from my tree, this will show
up in subsequent patch revisions.

Thanks Rusty.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 16:00:35 -0700 (PDT)
Message-ID: <20070607.160035.00774597.davem@davemloft.net>
References: <1181253445.4071.4.camel@localhost>
	<20070607.154421.109060486.davem@davemloft.net>
	<1181256848.4071.57.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jeff@garzik.org, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933374AbXFGXAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 19:00:19 -0400
In-Reply-To: <1181256848.4071.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 07 Jun 2007 18:54:08 -0400

> On Thu, 2007-07-06 at 15:44 -0700, David Miller wrote:
> > From: jamal <hadi@cyberus.ca>
> > Date: Thu, 07 Jun 2007 17:57:25 -0400
> > 
> > > I empathize but take a closer look; seems mostly useless.
> > 
> > I thought E1000 still uses LLTX, and if so then multiple cpus can most
> > definitely get into the ->hard_start_xmit() in parallel.
> 
> AFAICS, only one CPU can dequeue from the qdisc i.e s/he who holds
> __LINK_STATE_QDISC_RUNNING is the only one who can call qdisc_restart
> and only s/he can enter ->hard_start_xmit().
> 
> Am i missing something?

That's right we fixed that the other week.

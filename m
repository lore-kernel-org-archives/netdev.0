From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Add napi_sycnhronize() to sync with napi poll
Date: Thu, 18 Oct 2007 09:59:57 +1000
Message-ID: <1192665597.12789.0.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
	 <1192658654.6783.43.camel@pasglop>
	 <1192664183.13993.30.camel@localhost.localdomain>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47573 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756920AbXJRAAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:00:52 -0400
In-Reply-To: <1192664183.13993.30.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-10-17 at 18:36 -0500, Josh Boyer wrote:
> On Thu, 2007-10-18 at 08:04 +1000, Benjamin Herrenschmidt wrote:
> > net: Add __napi_synchronize() to sync with napi poll
> > 
> > The EMAC driver which needs to handle multiple devices with one
> > NAPI instance implements its own per-channel disable bit. However,
> > when setting such a bit, it needs to synchronize with the poller
> > (that is make sure that any pending poller instance has completed,
> > or is started late enough to see that disable bit).
> > 
> > This implements a low level __napi_synchronize() function to acheive
> > that. The underscores are to emphasis the low level aspect of it and
> > to discourage driver writers who don't know what they are doing to
> > use it (to please DaveM :-)
> 
> Erm.. your commit log calls it __napi_synchronize still.

The commit is a mistake, I sent a patch to rename it, or did I miss
something ?

Ben.



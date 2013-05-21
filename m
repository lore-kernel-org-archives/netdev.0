From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next 2/2] xen-netfront: split event
 channels feature support
Date: Tue, 21 May 2013 12:28:25 -0400
Message-ID: <20130521162825.GA3669@phenom.dumpdata.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
 <1369090931-27306-3-git-send-email-wei.liu2@citrix.com>
 <519B78F5.5020301@citrix.com>
 <20130521134149.GN32007@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39131 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab3EUQ2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 12:28:35 -0400
Content-Disposition: inline
In-Reply-To: <20130521134149.GN32007@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 02:41:49PM +0100, Wei Liu wrote:
> On Tue, May 21, 2013 at 02:39:01PM +0100, David Vrabel wrote:
> [...]
> > > +	info->rx_evtchn = info->tx_evtchn;
> > > +	info->rx_irq = info->tx_irq = err;
> > > +	dev_info(&info->xbdev->dev,
> > > +		 "single event channel, evtchn = %d, irq = %d\n",
> > > +		 info->tx_evtchn, info->tx_irq);
> > 
> > This message is pointless chatter as the information is available
> > elsewhere.  Please remove.
> > 
> 
> Do you mean /proc/interrupt by "elsewhere"? Information there doesn't
> give you irq<->evtchn mapping info.

If you really want to, that should be implemented via an DebugFS entry that can
be driven from drivers/xen/events.c. As the events.c is the generic code that sets
up the Xen events, pirqs, ipis, <-> Linux IRQs.

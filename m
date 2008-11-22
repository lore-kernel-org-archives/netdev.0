From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/22] efx: convert to net_device_ops
Date: Fri, 21 Nov 2008 17:33:50 -0800 (PST)
Message-ID: <20081121.173350.254390859.davem@davemloft.net>
References: <20081121232138.343333942@vyatta.com>
	<20081121232239.826434876@vyatta.com>
	<20081122004513.GE32518@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756393AbYKVBdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:33:51 -0500
In-Reply-To: <20081122004513.GE32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 22 Nov 2008 00:45:14 +0000

> Stephen Hemminger wrote:
> > Convert driver to new net_device_ops. Compile tested only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

> (But the driver name is sfc; "efx" is an historical reference.)

I fixed this up in the commit message, thanks.

> > -	if (net_dev->open == efx_net_open && event == NETDEV_CHANGENAME) {
> > +	if (net_dev->netdev_ops == &efx_netdev_ops && event == NETDEV_CHANGENAME) {
> 
> Also, this line should be wrapped now.

I think this is being overly picky, and it's OK to elide this in
this type of change I think.

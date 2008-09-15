From: Jeff Garzik <jeff@garzik.org>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Sun, 14 Sep 2008 23:14:14 -0400
Message-ID: <20080915031414.GA3028@havoc.gtf.org>
References: <20080821120409.GA2226@x200.localdomain> <20080821.050857.131314665.davem@davemloft.net> <20080914142654.3114cb3a@osprey.hogchain.net> <20080914.165655.193720725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jacliburn@bellsouth.net, adobriyan@gmail.com, csnook@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51444 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431AbYIODOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Sep 2008 23:14:15 -0400
Content-Disposition: inline
In-Reply-To: <20080914.165655.193720725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 04:56:55PM -0700, David Miller wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> Date: Sun, 14 Sep 2008 14:26:54 -0500
> 
> > Should a netdev driver be coded such that a watchdog transmit timeout
> > never occurs?
> > 
> > [ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> > 
> > Or is a watchdog timeout an expected occurrence if a cable is
> > unplugged/plugged?
> 
> If the cable is unplugged, netif_carrier_off() will be (or should
> be) invoked by the driver, and that cancels the watchdog timer.

100% correct :)

As Stephen noted, a transmit timeout is an unhandled condition plain and
simple -- either unhandled by the driver or unhandled by the hardware.

	Jeff




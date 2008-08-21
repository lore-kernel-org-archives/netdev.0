From: David Miller <davem@davemloft.net>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Thu, 21 Aug 2008 05:08:57 -0700 (PDT)
Message-ID: <20080821.050857.131314665.davem@davemloft.net>
References: <20080821115849.GA2126@x200.localdomain>
	<20080821.045910.61585911.davem@davemloft.net>
	<20080821120409.GA2226@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, csnook@redhat.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752165AbYHUMI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:08:57 -0400
In-Reply-To: <20080821120409.GA2226@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: adobriyan@gmail.com
Date: Thu, 21 Aug 2008 16:04:09 +0400

> On Thu, Aug 21, 2008 at 04:59:10AM -0700, David Miller wrote:
> > From: adobriyan@gmail.com
> > Date: Thu, 21 Aug 2008 15:58:49 +0400
> > 
> > > This message happens more or less every reboot, sometimes cable unplug/plug is needed
> > > to restore connectivity, otherwise card is working fine.
> > 
> > What kernel version.... no, I can figure it out via osmosis never mind!
> > :-)
> 
> WARN already prints kernel version. ;-)
> 
> [ 2086.052503] Pid: 0, comm: swapper Not tainted 2.6.27-rc4-netns-nf #4
> 						 ^^^^^^^^^^^^^^^^^^^
> 
> And before you ask, "-netns-nf" part doesn't matter, it happens with
> strictly mainline kernels too and started around multiqueue TX changes,
> IIRC.

It's a simple transmit timeout error.

Perhaps atl1 doesn't call netif_carrier_off() in all the places that it
should.

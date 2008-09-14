From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Sun, 14 Sep 2008 14:26:54 -0500
Message-ID: <20080914142654.3114cb3a@osprey.hogchain.net>
References: <20080821115849.GA2126@x200.localdomain>
	<20080821.045910.61585911.davem@davemloft.net>
	<20080821120409.GA2226@x200.localdomain>
	<20080821.050857.131314665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, csnook@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([204.127.217.106]:50580 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbYINTeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 15:34:16 -0400
In-Reply-To: <20080821.050857.131314665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Aug 2008 05:08:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: adobriyan@gmail.com
> Date: Thu, 21 Aug 2008 16:04:09 +0400
> 
> > On Thu, Aug 21, 2008 at 04:59:10AM -0700, David Miller wrote:
> > > From: adobriyan@gmail.com
> > > Date: Thu, 21 Aug 2008 15:58:49 +0400
> > > 
> > > > This message happens more or less every reboot, sometimes cable
> > > > unplug/plug is needed to restore connectivity, otherwise card
> > > > is working fine.
> > > 
> > > What kernel version.... no, I can figure it out via osmosis never
> > > mind! :-)
> > 
> > WARN already prints kernel version. ;-)
> > 
> > [ 2086.052503] Pid: 0, comm: swapper Not tainted
> > 2.6.27-rc4-netns-nf #4 ^^^^^^^^^^^^^^^^^^^
> > 
> > And before you ask, "-netns-nf" part doesn't matter, it happens with
> > strictly mainline kernels too and started around multiqueue TX
> > changes, IIRC.
> 
> It's a simple transmit timeout error.
> 
> Perhaps atl1 doesn't call netif_carrier_off() in all the places that
> it should.

For reference, the original report from Alexey on this matter is here:

http://marc.info/?l=linux-netdev&m=121931988219314&w=2

To which Dave responded above, "It's a simple transmit timeout error."

Should a netdev driver be coded such that a watchdog transmit timeout
never occurs?

[ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit timed out

Or is a watchdog timeout an expected occurrence if a cable is
unplugged/plugged?

Thanks,
Jay

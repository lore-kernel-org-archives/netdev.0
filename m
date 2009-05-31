From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: tulip_rxtx_stop() on Cobalt Qube2
Date: Sun, 31 May 2009 17:43:42 -0600
Message-ID: <20090531234342.GD3291@lackof.org>
References: <200905011238.59345.florian@openwrt.org> <20090531014036.GA23050@lackof.org> <200905312302.22608.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org,
	kyle@mcmartin.ca
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:40885 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbZEaXnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 19:43:40 -0400
Content-Disposition: inline
In-Reply-To: <200905312302.22608.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 31, 2009 at 11:02:22PM +0200, Florian Fainelli wrote:
> Hi Grant,
...
> > The RX/TX engines are in a wedged state to begin with. :(
> 
> I suppose this is due to the Bootloader, either CoLo or the original Cobalt 
> microservers bootloader.

Yeah - either bootloader or BIOS - whatever talked to the NIC most recently.

...
> > I have not tested or even compiled this patch...will do so on parisc/ia64
> > machines once I get some feedback on this patch.
> >
> > And I just noticed pci_clear_master() is not called *anywhere*. :(
> > Need to add such a call after tulip_stop_rxtx() some place (many places?).
> > This patch is just RFC and not suitable for merging upstream.
> 
> The patch below does not help on my Qube2, I am still having the same message 
> appearing.

Are you sure?

I thought I removed all calls to tulip_stop_rxtx() in the initialization
code path and didn't think it would get called. Did I overlook one?
Can you add "dump_stack()" to tulip_stop_rxtx() failure case?

Can you also modify the driver version to make sure you are using
the correct/most recenly built module?

And the please post the dmesg output from the driver again (plus 10
lines of output  before and after).

thanks,
grant

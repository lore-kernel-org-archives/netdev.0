From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] PA Semi PWRficient Ethernet driver
Date: Tue, 30 Jan 2007 14:53:54 -0600
Message-ID: <20070130205354.GA27922@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070129102233.27f236ee@freekitty> <20070130014107.GA18935@lixom.net> <45BEAE9E.4000802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:53909 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbXA3UrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 15:47:15 -0500
Content-Disposition: inline
In-Reply-To: <45BEAE9E.4000802@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 09:34:06PM -0500, Jeff Garzik wrote:
> Olof Johansson wrote:
> >Right now it's guaranteed that the interrupts will not be shared. They're
> >fixed for the on-chip devices, and no other driver should be binding to
> >the same channels (and thus irqs).
> >
> >If it changes in the future, the driver would need other rework as well.
> 
> Nonetheless, it is far more sane to check for work, and return if no 
> work.  Who knows if the hardware will signal an interrupt early or late.

Easy enough. Added in the next version.

> >>>+static struct pci_driver pasemi_mac_driver = {
> >>>+   .name = "pasemi_mac",
> >>>+   .id_table = pasemi_mac_pci_tbl,
> >>>+   .probe = pasemi_mac_probe,
> >>Don't you need a remove routine?
> >
> >No hotplug support at this time, so I didn't see any use in providing one.
> 
> module remove.

Oh, good point. Added in the next version to be posted.


Thanks,

-Olof

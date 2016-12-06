From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Gigabit ethernet driver for Alacritechs SLIC devices (v4)
Date: Tue, 6 Dec 2016 17:40:39 +0100
Message-ID: <20161206164039.GA7091@kroah.com>
References: <1480975637-18245-1-git-send-email-LinoSanfilippo@gmx.de>
 <20161206.113004.1297109434722530511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LinoSanfilippo@gmx.de, charrer@alacritech.com, liodot@gmail.com,
        andrew@lunn.ch, roszenrami@gmail.com, markus.boehme@mailbox.org,
        f.fainelli@gmail.com, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:46526 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbcLFQkc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:40:32 -0500
Content-Disposition: inline
In-Reply-To: <20161206.113004.1297109434722530511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 11:30:04AM -0500, David Miller wrote:
> From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> Date: Mon,  5 Dec 2016 23:07:15 +0100
> 
> > this is the forth version of the slicoss gigabit ethernet driver (which is a
> > rework of the driver from Alacritech which can currently be found under
> > drivers/staging/slicoss). The driver is supposed to support Mojave, Oasis and
> > Kalahari cards, for both copper and fiber.
> > 
> > If this code is accepted the staging version can be removed.
> > 
> > The driver has been tested on a SEN2104ET adapter (4 Port PCIe copper).
> 
> I've applied this series, nice work.
> 
> But realize that if you use SLICOSS as the Kconfig symbol to select
> this driver, then while the staging driver is still in the tree it
> will enable both drivers which both want to attach to the same exact
> device IDs.

If you have taken this in your tree now, I will go delete the staging
driver from the staging tree, so we will not have that issue.  Should I
do that now?

thanks,

greg k-h

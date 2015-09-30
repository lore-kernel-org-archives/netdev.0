From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA driver - how to glue to a PCI based NIC's mdio?
Date: Wed, 30 Sep 2015 23:40:52 +0200
Message-ID: <20150930214052.GG20219@lunn.ch>
References: <CAJ+vNU2rf0r9V3DfF1-=hpEhdqxkDHz-LmHWOJqscLdsw2EDEA@mail.gmail.com>
 <20150930211210.GD20219@lunn.ch>
 <CAJ+vNU2SUpsQ+7dwPfR6EHVofpvVFF42KO=YUDaarLaDwWvXFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38214 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200AbbI3Vkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 17:40:53 -0400
Content-Disposition: inline
In-Reply-To: <CAJ+vNU2SUpsQ+7dwPfR6EHVofpvVFF42KO=YUDaarLaDwWvXFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > information to the NIC's device driver. Better would be to have a
> > small shim driver which is loaded on your PCI_ID/DEVICE_ID. That would
> > instantiate the NIC driver, and insert a DSA platform device.
> 
> I was thinking of this as well, but then I would still need that shim
> to know the netdevice that the driver I'm shimming creates so I can't
> figure a way to do it without touching the PCI driver.

You can probably get that from the PCI information you have:

# /sys/devices/pci0000:00/0000:00:1c.2/0000:06:00.0 is the PCIe device. And it has

# /sys/devices/pci0000:00/0000:00:1c.2/0000:06:00.0/net$ ls -l
total 0
drwxr-xr-x 5 root root 0 Aug 19 18:23 eth0

So the linking is there.

   Andrew

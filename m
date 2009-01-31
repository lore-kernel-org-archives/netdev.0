From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 01:47:02 +0100
Message-ID: <200901310147.02897.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310138.51214.rjw@sisk.pl> <20090131004416.GC13709@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:51084 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137AbZAaArr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 19:47:47 -0500
In-Reply-To: <20090131004416.GC13709@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Ingo Molnar wrote:
> 
> * Rafael J. Wysocki <rjw@sisk.pl> wrote:
> 
> > +static struct dev_pm_ops pcie_portdrv_pm_ops = {
> > +	.suspend = pcie_port_device_suspend,
> > +	.resume = pcie_port_device_resume,
> > +	.freeze = pcie_port_device_suspend,
> > +	.thaw = pcie_port_device_resume,
> > +	.poweroff = pcie_port_device_suspend,
> > +	.restore = pcie_port_device_resume,
> > +};
> 
> pet peeve: could we please use vertical spaces wherever they improve the 
> code?
> 
> Something like:
> 
> static struct dev_pm_ops pcie_portdrv_pm_ops = {
> 	.suspend	= pcie_port_device_suspend,
> 	.resume		= pcie_port_device_resume,
> 	.freeze		= pcie_port_device_suspend,
> 	.thaw		= pcie_port_device_resume,
> 	.poweroff	= pcie_port_device_suspend,
> 	.restore	= pcie_port_device_resume,
> };
> 
> ... and it all becomes clear at a glance. Please?

OK

Rafael

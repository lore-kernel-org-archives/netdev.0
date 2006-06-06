From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Mon, 5 Jun 2006 23:50:16 -0700
Message-ID: <20060606065016.GB16832@suse.de>
References: <2005123213211@nnikde.cz> <20060605202007.B464FC7B73@atrey.karlin.mff.cuni.cz> <20060605205309.GA31061@kroah.com> <20060606011818.GA4135@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Jiri Slaby <jirislaby@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, jgarzik@pobox.com,
	netdev@vger.kernel.org, mb@bu3sch.de, st3@riseup.net,
	linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750812AbWFFGxF@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20060606011818.GA4135@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 09:18:18PM -0400, Jeff Garzik wrote:
> On Mon, Jun 05, 2006 at 01:53:09PM -0700, Greg KH wrote:
> > Why not just use the proper pci interface?  Why poke around in another
> > pci device to steal an irq, when that irq might not even be valid?
> > (irqs are not valid until pci_enable_device() is called on them...)
> 
> Answered this question the last time you asked.
> 
> Answer:  this is an embedded platform that needs such poking.  The
> wireless device is _another_ device.

Ugh, sorry, too many patches, too many different threads...  You are
right...

greg k-h

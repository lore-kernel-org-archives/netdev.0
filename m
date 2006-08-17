From: Greg KH <greg@kroah.com>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 08:52:07 -0700
Message-ID: <20060817155207.GA7426@kroah.com>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl> <20060817055814.GA14950@kroah.com> <44E46280.2020109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:3537 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S932551AbWHQQCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 12:02:51 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <44E46280.2020109@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 08:35:12AM -0400, Jeff Garzik wrote:
> Greg KH wrote:
> >On Thu, Aug 17, 2006 at 04:26:35AM +0000, Michal Piotrowski wrote:
> >>Hi,
> >>
> >>pci_module_init is obsolete.
> >>
> >>This patch series converts pci_module_init to pci_register_driver.
> >>
> >>
> >>Can I remove this?
> >>
> >>include/linux/pci.h:385
> >>/*
> >> * pci_module_init is obsolete, this stays here till we fix up all usages 
> >> of it
> >> * in the tree.
> >> */
> >>#define pci_module_init pci_register_driver
> >
> >As repeated numerous times, it's up to the network developers if they
> >will take this or not.
> >
> >I'll hold off on taking this series, please push it through the driver
> >subsystem maintainers.
> 
> It's already in subsystem trees, in fact.

Great, it can wait until 2.6.19.

> But it is most definitely not 2.6.18-rc material :)

Agreed.

thanks,

greg k-h

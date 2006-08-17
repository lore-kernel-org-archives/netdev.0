From: Greg KH <greg@kroah.com>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver conversion
Date: Wed, 16 Aug 2006 22:58:14 -0700
Message-ID: <20060817055814.GA14950@kroah.com>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:16269 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S964823AbWHQLp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 07:45:58 -0400
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Content-Disposition: inline
In-Reply-To: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 04:26:35AM +0000, Michal Piotrowski wrote:
> 
> Hi,
> 
> pci_module_init is obsolete.
> 
> This patch series converts pci_module_init to pci_register_driver.
> 
> 
> Can I remove this?
> 
> include/linux/pci.h:385
> /*
>  * pci_module_init is obsolete, this stays here till we fix up all usages of it
>  * in the tree.
>  */
> #define pci_module_init pci_register_driver

As repeated numerous times, it's up to the network developers if they
will take this or not.

I'll hold off on taking this series, please push it through the driver
subsystem maintainers.

thanks,

greg k-h

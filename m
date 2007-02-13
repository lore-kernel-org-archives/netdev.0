From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 15:01:24 -0500
Message-ID: <20070213200124.GD16991@havoc.gtf.org>
References: <1171397612.18944.25.camel@rh4> <20070213115825.0a6119ed@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46303 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbXBMUB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:01:29 -0500
Content-Disposition: inline
In-Reply-To: <20070213115825.0a6119ed@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 11:58:25AM -0800, Stephen Hemminger wrote:
> I think you have to move the original pci_save_state call, otherwise
> you will call pci_save_state twice and leak memory.  pci_save_state
> allocates memory to store MSI and other information. Look at pci_save_pcie_state
> etc.

That's a bug in the PCI layer.  Patches welcome...

	Jeff




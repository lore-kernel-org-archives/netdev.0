From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgb: don't print error if pci_enable_msi() fails, cleanup
 minor leak
Date: Thu, 17 May 2007 20:46:18 -0400
Message-ID: <464CF75A.8000600@garzik.org>
References: <20070517222906.25352.31886.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, cebbert@redhat.com, hpa@zytor.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43579 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479AbXERAqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:46:23 -0400
In-Reply-To: <20070517222906.25352.31886.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> pci_enable_msi calls can fail for normal operational reasons. Driver
> should not print an error message in that case. Fix a leak that leaves
> msi enabled if pci_request_irq fails. We can remove CONFIG_PCI_MSI
> ifdefs alltogether
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb.h      |    2 --
>  drivers/net/ixgb/ixgb_main.c |   36 +++++++++++++++---------------------
>  2 files changed, 15 insertions(+), 23 deletions(-)

applied



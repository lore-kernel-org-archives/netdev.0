From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Thu, 17 May 2007 20:46:27 -0400
Message-ID: <464CF763.5040306@garzik.org>
References: <20070516084946.29078.55152.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	hpa@zytor.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43590 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756888AbXERAq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:46:29 -0400
In-Reply-To: <20070516084946.29078.55152.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> pci_enable_msi failure is a normal event so we should not print any error.
> Going over the code I spotted a missing pci_disable_msi() leak when irq
> allocation fails. The whole code also needed a cleanup, so I combined the
> two different calls to pci_request_irq into a single call making this
> look a lot better. All #ifdef CONFIG_PCI_MSI's have been removed.
> 
> Compile tested with both CONFIG_PCI_MSI enabled and disabled.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: H. Peter Anvin <hpa@zytor.com>
> ---
> 
>  drivers/net/e1000/e1000.h      |    4 +---
>  drivers/net/e1000/e1000_main.c |   39 ++++++++++++++-------------------------
>  2 files changed, 15 insertions(+), 28 deletions(-)

applied



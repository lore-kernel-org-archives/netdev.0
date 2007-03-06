From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pcnet32: only allocate init_block dma consistent
Date: Tue, 06 Mar 2007 06:13:14 -0500
Message-ID: <45ED4CCA.7030606@garzik.org>
References: <20070306021037.GA7139@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53225 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965849AbXCFLNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:13:16 -0500
In-Reply-To: <20070306021037.GA7139@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> The patch below moves the init_block out of the private struct and
> only allocates init block with pci_alloc_consistent.
> 
> This has two effects:
> 
> 1. Performance increase for non cache coherent machines, because the
>    CPU only data in the private struct are now cached
> 
> 2. locks are working now for platforms, which need to have locks
>    in cached memory
> 
> Also use netdev_priv() instead of dev->priv
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

please separate the netdev_priv() change into a separate, precursor 
patch, and resend both



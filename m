From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Fri, 09 Mar 2007 12:01:33 -0500
Message-ID: <45F192ED.6060704@garzik.org>
References: <20070306184523.GA23268@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57955 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767416AbXCIRBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 12:01:34 -0500
In-Reply-To: <20070306184523.GA23268@verizon.net>
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
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> Acked-by: Don Fry <pcnet32@verizon.net>
> ---
>  drivers/net/pcnet32.c |   77 ++++++++++++++++++++++---------------------------
>  1 files changed, 34 insertions(+), 43 deletions(-)

applied 1-2, with included trailing whitespace noise




From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH ] pcnet32: Fix PCnet32 performance bug on non-coherent
 architecutres
Date: Tue, 06 Mar 2007 06:15:22 -0500
Message-ID: <45ED4D4A.3020004@garzik.org>
References: <20070306021309.GB7139@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53265 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934080AbXCFLPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:15:24 -0500
In-Reply-To: <20070306021309.GB7139@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> The PCnet32 driver always passed the the size of the largest possible packet
> to the pci_dma_sync_single_for_cpu and pci_dma_sync_single_for_device.
> This results in a fairly large "colateral damage" in the caches and makes
> the flush operation itself much slower.  On a system with a 40MHz CPU this
> patch increases network bandwidth by about 12%.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> Acked-by: Don Fry <pcnet32@verizon.net>

applied



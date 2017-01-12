From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: kill off pci_enable_msi_{exact,range}
Date: Thu, 12 Jan 2017 15:29:00 -0600
Message-ID: <20170112212900.GE8312@bhelgaas-glaptop.roam.corp.google.com>
References: <1483994260-19797-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org,
        Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org,
        Tom Lendacky <thomas.lendacky@amd.com>
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59192 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdALV3E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 16:29:04 -0500
Content-Disposition: inline
In-Reply-To: <1483994260-19797-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 09:37:37PM +0100, Christoph Hellwig wrote:
> I had hope that we could kill these old interfaces of for 4.10-rc,
> but as of today Linus tree still has two users:
> 
>  (1) the cobalt media driver, for which I sent a patch long time ago,
>      it got missed in the merge window.
>  (2) the new xgbe driver was merged in 4.10-rc but used the old interfaces
>      anyway
> 
> This series resend the patch for (1) and adds a new one for (2), as well
> as having the final removal patch behind it.  Maybe we should just queue
> up all three together in the PCI tree for 4.11?

Applied all three (with Tom's ack on the amd-xgbe patch) to pci/msi for
v4.11, thanks!

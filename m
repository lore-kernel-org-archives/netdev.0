From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Mon, 27 Mar 2017 19:11:48 +0200
Message-ID: <20170327171148.GB28815@lst.de>
References: <20170327082936.6830-1-hch@lst.de> <20170327082936.6830-6-hch@lst.de> <83f97789-0817-7549-bfa9-1f8dcb0c26d9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, bhelgaas@google.com,
        davem@davemloft.net, netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42304 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751350AbdC0RMb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 13:12:31 -0400
Content-Disposition: inline
In-Reply-To: <83f97789-0817-7549-bfa9-1f8dcb0c26d9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 09:59:35AM -0700, David Daney wrote:
> On 03/27/2017 01:29 AM, Christoph Hellwig wrote:
>> Unused now that all callers switched to pci_alloc_irq_vectors.
>>
>
> And you are aware that the ThunderX GPIO driver that I am attempting to 
> merge uses this interface.
>
> If this patch gets merged, should I ask to revert it when the GPIO driver 
> goes in?

No.  You should not use pci_enable_msix in your new driver as I told
you before.

> You offer no solution for drivers that would benefit from using a sparse 
> sub set of the available MSI-X vectors.

Use pci_enable_msix_{exact,range} for now, as I told you before.

From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/3] xgbe: switch to pci_irq_alloc_vectors
Date: Wed, 11 Jan 2017 10:03:57 +0100
Message-ID: <20170111090357.GB7350@lst.de>
References: <1483994260-19797-1-git-send-email-hch@lst.de> <1483994260-19797-3-git-send-email-hch@lst.de> <11ed330c-84e9-79e9-7945-ca17a497359c@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, linux-pci@vger.kernel.org,
        Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:34370 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751641AbdAKJD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 04:03:59 -0500
Content-Disposition: inline
In-Reply-To: <11ed330c-84e9-79e9-7945-ca17a497359c@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 12:40:10PM -0600, Tom Lendacky wrote:
> On 1/9/2017 2:37 PM, Christoph Hellwig wrote:
> > The newly added xgbe drivers uses the deprecated pci_enable_msi_exact
> > and pci_enable_msix_range interfaces.  Switch it to use
> > pci_irq_alloc_vectors instead.
> 
> I was just working on switching over to this API with some additional
> changes / simplification.  I'm ok with using this patch so that you get
> the API removal accomplished.  Going through the PCI tree just means
> it will probably be easier for me to hold off on the additional changes
> I wanted to make until later.

Hi Tom,

if you have a better patch I'd be more than happy to use that one instead,
this one was intended as a stupid search and replace.  The important
part for me is to get the two conversions and the interface removal
in together.

E.g. I've alreayd wondered why the driver requires the exact vector
number for MSI and a variable one for MSI-X, and there certainly is
all kinds of opportunity for cosmetic cleanup.

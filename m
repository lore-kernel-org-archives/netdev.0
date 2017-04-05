From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] net: thunderx: Switch to pci_alloc_irq_vectors
Date: Wed, 5 Apr 2017 08:27:40 +0200
Message-ID: <20170405062740.GB26470@lst.de>
References: <1491298146-13609-1-git-send-email-tsrinivasulu@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
        tsrinivasulu@cavium.com, hch@lst.de
To: dev.srinivasulu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:55412 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751298AbdDEG1m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 02:27:42 -0400
Content-Disposition: inline
In-Reply-To: <1491298146-13609-1-git-send-email-tsrinivasulu@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 04, 2017 at 02:59:06PM +0530, dev.srinivasulu@gmail.com wrote:
> From: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
> 
> Remove deprecated pci_enable_msix API in favour of it's
> successor pci_alloc_irq_vectors.
> 
> Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>

Looks good.

Are you fine with me queueing this up together with the other
pci_enable_msix() removal patches?

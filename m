From: David Miller <davem@davemloft.net>
Subject: Re: kill off pci_enable_msi_{exact,range}
Date: Tue, 10 Jan 2017 20:20:24 -0500 (EST)
Message-ID: <20170110.202024.798810764764725086.davem@davemloft.net>
References: <1483994260-19797-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, mchehab@s-opensource.com,
        netdev@vger.kernel.org, linux-media@vger.kernel.org
To: hch@lst.de
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1483994260-19797-1-git-send-email-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Mon,  9 Jan 2017 21:37:37 +0100

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

Feel free to toss this into the PCI tree.

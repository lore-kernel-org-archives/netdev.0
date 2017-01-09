From: Christoph Hellwig <hch@lst.de>
Subject: kill off pci_enable_msi_{exact,range}
Date: Mon,  9 Jan 2017 21:37:37 +0100
Message-ID: <1483994260-19797-1-git-send-email-hch@lst.de>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <linux-media-owner@vger.kernel.org>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had hope that we could kill these old interfaces of for 4.10-rc,
but as of today Linus tree still has two users:

 (1) the cobalt media driver, for which I sent a patch long time ago,
     it got missed in the merge window.
 (2) the new xgbe driver was merged in 4.10-rc but used the old interfaces
     anyway

This series resend the patch for (1) and adds a new one for (2), as well
as having the final removal patch behind it.  Maybe we should just queue
up all three together in the PCI tree for 4.11?

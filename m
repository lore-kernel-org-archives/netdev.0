From: Christoph Hellwig <hch@lst.de>
Subject: remove dma_supported and pci_dma_supported as public APIs
Date: Sat,  3 Oct 2015 17:19:24 +0200
Message-ID: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All driver should be using dma_set_mask / pci_set_dma_mask to try
to set the dma mask instead of just querying it.  Without that some
iommu implementations may not work.

pci_dma_supported is removed entirely, but dma_supported stays for
dma_ops implementations for now.

From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH 0/5] more about numa_node with struct device
Date: Tue, 10 Jul 2007 16:52:19 -0700
Message-ID: <200707101652.20613.yinghai.lu@sun.com>
Reply-To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:38444 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762010AbXGKABA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:01:00 -0400
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

these are revised or new patch with numa_node in struct device in addition to 

andrew already sent to andi
x86_64-get-mp_bus_to_node-as-early.patch
it will make all pci_dev->dev.numa_node correctly.

still in -mm, and andrew will re-review for 2.6.23
dma-make-dma-pool-to-use-kmalloc_node.patch

in greg tree
usb-make-the-usb_device-numa_node-get-assigned-from-controller.patch

Thanks

Yinghai Lu

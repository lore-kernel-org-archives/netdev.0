From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Mon, 27 Mar 2017 14:06:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFBAAD0@AcuExch.aculab.com>
References: <20170327082936.6830-1-hch@lst.de>
 <20170327082936.6830-6-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: 'Christoph Hellwig' <hch@lst.de>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netanel@annapurnalabs.com" <netanel@annapurnalabs.com>,
        "jcliburn@gmail.com" <jcliburn@gmail.com>,
        "chris.snook@gmail.com" <chris.snook@gmail.com>,
        "sgoutham@cavium.com" <sgoutham@cavium.com>,
        "rric@kernel.org" <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:52121 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752832AbdC0OHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 10:07:07 -0400
In-Reply-To: <20170327082936.6830-6-hch@lst.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig
> Sent: 27 March 2017 09:30
>
> Unused now that all callers switched to pci_alloc_irq_vectors.

Apart from all the 'out of tree' drivers that will need
fixing and a conditional compile added.

At least give us a couple of kernel versions to get it sorted.

	David

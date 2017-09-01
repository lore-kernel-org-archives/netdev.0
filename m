From: Christoph Hellwig <hch@lst.de>
Subject: hns3 use of pci_enable_msix_range
Date: Fri, 1 Sep 2017 10:26:33 +0200
Message-ID: <20170901082633.GA23568@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daode Huang <huangdaode@hisilicon.com>,
        lipeng <lipeng321@huawei.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Wei Hu <xavier.huwei@huawei.com>, netdev@vger.kernel.org
To: Salil <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:59575 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751485AbdIAI0f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 04:26:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Salil,

can you please switch your new hns3 driver to use pci_alloc_irq_vectors
instead of the deprecated pci_enable_msix_range interface?  Take a
look at Documentation/PCI/MSI-HOWTO.txt for the details.

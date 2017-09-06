From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: hns3 use of pci_enable_msix_range
Date: Wed, 6 Sep 2017 08:43:10 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B89D963@FRAEML521-MBX.china.huawei.com>
References: <20170901082633.GA23568@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:34334 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbdIFIn1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 04:43:27 -0400
In-Reply-To: <20170901082633.GA23568@lst.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,
Thanks for bringing this into notice. I will change and send this patch
in the next cycle after we have tested it internally. 

Best regards
Salil
> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@lst.de]
> Sent: Friday, September 01, 2017 9:27 AM
> To: Salil Mehta
> Cc: huangdaode; lipeng (Y); Zhuangyuzeng (Yisen); Huwei (Xavier);
> netdev@vger.kernel.org
> Subject: hns3 use of pci_enable_msix_range
> 
> Hi Salil,
> 
> can you please switch your new hns3 driver to use pci_alloc_irq_vectors
> instead of the deprecated pci_enable_msix_range interface?  Take a
> look at Documentation/PCI/MSI-HOWTO.txt for the details.

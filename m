From: "Ariel Elior" <ariele@broadcom.com>
Subject: RE: [PATCH 02/16] bnx2x: clean up unnecessary MSI/MSI-X
 capability find
Date: Thu, 8 Aug 2013 13:18:10 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1BEB5CDB@SJEXCHMB05.corp.ad.broadcom.com>
References: <1375966956-36436-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Hanjun Guo" <guohanjun@huawei.com>,
	"jiang.liu@huawei.com" <jiang.liu@huawei.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yijing Wang" <wangyijing@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2689 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757835Ab3HHNS0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:18:26 -0400
In-Reply-To: <1375966956-36436-1-git-send-email-wangyijing@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH 02/16] bnx2x: clean up unnecessary MSI/MSI-X capability
> find
> 
> PCI core will initialize device MSI/MSI-X capability in
> pci_msi_init_pci_dev(). So device driver should use
> pci_dev->msi_cap/msix_cap to determine whether the device
> support MSI/MSI-X instead of using
> pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
> Access to PCIe device config space again will consume more time.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Thanks Yijing.
Acked-by: Ariel Elior <ariele@broadcom.com>

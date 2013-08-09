From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/16] bnx2x: clean up unnecessary MSI/MSI-X capability
 find
Date: Fri, 09 Aug 2013 13:50:38 -0700 (PDT)
Message-ID: <20130809.135038.532842082214913014.davem@davemloft.net>
References: <1375966956-36436-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guohanjun@huawei.com, jiang.liu@huawei.com, eilong@broadcom.com,
	netdev@vger.kernel.org
To: wangyijing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031089Ab3HIUuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 16:50:39 -0400
In-Reply-To: <1375966956-36436-1-git-send-email-wangyijing@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 8 Aug 2013 21:02:36 +0800

> PCI core will initialize device MSI/MSI-X capability in
> pci_msi_init_pci_dev(). So device driver should use
> pci_dev->msi_cap/msix_cap to determine whether the device
> support MSI/MSI-X instead of using
> pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
> Access to PCIe device config space again will consume more time.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied.

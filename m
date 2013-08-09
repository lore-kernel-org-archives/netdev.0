From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/16] netxen: clean up unnecessary MSI/MSI-X
 capability find
Date: Fri, 09 Aug 2013 13:50:49 -0700 (PDT)
Message-ID: <20130809.135049.862807277944655465.davem@davemloft.net>
References: <1375966976-33428-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guohanjun@huawei.com, jiang.liu@huawei.com,
	manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org
To: wangyijing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031089Ab3HIUuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 16:50:50 -0400
In-Reply-To: <1375966976-33428-1-git-send-email-wangyijing@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 8 Aug 2013 21:02:56 +0800

> PCI core will initialize device MSI/MSI-X capability in
> pci_msi_init_pci_dev(). So device driver should use
> pci_dev->msi_cap/msix_cap to determine whether the device
> support MSI/MSI-X instead of using
> pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
> Access to PCIe device config space again will consume more time.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied.

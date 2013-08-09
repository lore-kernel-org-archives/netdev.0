From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/16] tg3: clean up unnecessary MSI/MSI-X capability
 find
Date: Fri, 09 Aug 2013 13:51:01 -0700 (PDT)
Message-ID: <20130809.135101.2061941695616790943.davem@davemloft.net>
References: <1375966992-33236-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guohanjun@huawei.com, jiang.liu@huawei.com, nsujir@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wangyijing@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375966992-33236-1-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 8 Aug 2013 21:03:12 +0800

> PCI core will initialize device MSI/MSI-X capability in
> pci_msi_init_pci_dev(). So device driver should use
> pci_dev->msi_cap/msix_cap to determine whether the device
> support MSI/MSI-X instead of using
> pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
> Access to PCIe device config space again will consume more time.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied.

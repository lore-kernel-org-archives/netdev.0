From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] amd8111e: use pdev->pm_cap instead of
 pci_find_capability(..,PCI_CAP_ID_PM)
Date: Wed, 19 Jun 2013 22:24:16 -0700 (PDT)
Message-ID: <20130619.222416.737701720649805813.davem@davemloft.net>
References: <1371542797-14964-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, guohanjun@huawei.com,
	jiang.liu@huawei.com, kaber@trash.net, wfp5p@virginia.edu,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: wangyijing@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371542797-14964-1-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 18 Jun 2013 16:06:37 +0800

> Pci core has been saved pm cap register offset by pdev->pm_cap in pci_pm_init()
> in init path. So we can use pdev->pm_cap instead of using
> pci_find_capability(pdev, PCI_CAP_ID_PM) for better performance and simplified code.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied.

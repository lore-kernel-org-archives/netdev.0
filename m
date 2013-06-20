From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] Bnx2x: remove redundant D0 power state set
Date: Wed, 19 Jun 2013 22:24:11 -0700 (PDT)
Message-ID: <20130619.222411.875430840716764954.davem@davemloft.net>
References: <1371542739-13552-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, guohanjun@huawei.com,
	jiang.liu@huawei.com, eilong@broadcom.com, netdev@vger.kernel.org
To: wangyijing@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371542739-13552-1-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 18 Jun 2013 16:05:39 +0800

> Pci_enable_device() will set device power state to D0,
> so it's no need to do it again in bnx2x_init_dev().
> Also remove redundant PM Cap find code, because pci core
> has been saved the pci device pm cap value.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied.

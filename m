From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: remove redundant pm init code
Date: Mon, 03 Jun 2013 00:49:16 -0700 (PDT)
Message-ID: <20130603.004916.406462343477494169.davem@davemloft.net>
References: <1370244981-11716-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	guohanjun@huawei.com, liuj97@gmail.com
To: wangyijing@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370244981-11716-1-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 3 Jun 2013 15:36:21 +0800

> Pci_enable_device() will set device pm state to D0, so
> it's no need to do it again in tg3_init_one().
> 
> Acked-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

This looks better, applied, thanks.

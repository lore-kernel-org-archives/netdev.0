From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sun, 18 Jun 2017 16:53:05 +0200
Message-ID: <20170618145305.GA4025@lunn.ch>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-3-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170613231035.494020-3-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2017 at 12:10:29AM +0100, Salil Mehta wrote:
> This patch adds the support of the HNAE3 (Hisilicon Network
> Acceleration Engine 3) framework support to the HNS3 driver.
> 
> Framework facilitates clients like ENET(HNS3 Ethernet Driver), RoCE
> and user-space Ethernet drivers (like ODP etc.) to register with HNAE3
> devices and their associated operations.

checkpatch throws out one warning in this file

CHECK: Comparison to NULL could be written "pos"
#3508: FILE: drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h:572:
+      for (pos = (head).ring; pos != NULL; pos = pos->next)

This one seems valid. Not all checkpatch warnings are.

     Andrew

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: make some bits preserved while setup
 forced mode
Date: Fri, 15 Apr 2016 20:13:40 -0400 (EDT)
Message-ID: <20160415.201340.75308332414545478.davem@davemloft.net>
References: <570E3488.9060403@huawei.com>
	<570F4A38.5090201@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	andrew@lunn.ch
To: wangweidong1@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570F4A38.5090201@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weidong Wang <wangweidong1@huawei.com>
Date: Thu, 14 Apr 2016 15:43:52 +0800

> When tested the PHY SGMII Loopback:
> 1.set the LOOPBACK bit,
> 2.set the autoneg to AUTONEG_DISABLE, it calls the
> genphy_setup_forced which will clear the bit.
> 
> The BMCR_LOOPBACK bit should be preserved.
> 
> As Florian pointed out that other bits should be preserved too.
> So I make the BMCR_ISOLATE and BMCR_PDOWN as well.
> 
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>

Applied, thank you.

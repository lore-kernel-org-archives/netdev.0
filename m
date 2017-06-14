From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Wed, 14 Jun 2017 04:55:52 +0200
Message-ID: <20170614025552.GC16215@lunn.ch>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-7-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170613231035.494020-7-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	if (le16_to_cpu(HCLGE_MDIO_STA_VAL(mdio_cmd->sta))) {
> +		dev_err(&hdev->pdev->dev, "mdio read data error\n");
> +		return -ENOMEM;
> +	}

If it is not zero, it is an error. !0 is always !0, big or little
endian, so there is no point doing the le16_to_cpu().

Where is the memory allocation which failed?

      Andrew

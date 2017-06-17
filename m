From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sat, 17 Jun 2017 11:56:49 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2D05@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-7-salil.mehta@huawei.com>
 <20170614025552.GC16215@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614025552.GC16215@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 3:56 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 6/8] net: hns3: Add MDIO support to
> HNS3 Ethernet driver for hip08 SoC
> 
> > +	if (le16_to_cpu(HCLGE_MDIO_STA_VAL(mdio_cmd->sta))) {
> > +		dev_err(&hdev->pdev->dev, "mdio read data error\n");
> > +		return -ENOMEM;
> > +	}
> 
> If it is not zero, it is an error. !0 is always !0, big or little
> endian, so there is no point doing the le16_to_cpu().
> 
> Where is the memory allocation which failed?
> 
>       Andrew
Agreed! Will remove this.

Thanks
Salil

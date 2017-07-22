From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 22 Jul 2017 23:31:10 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CC39@FRAEML521-MBX.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-3-salil.mehta@huawei.com>
 <20170618145305.GA4025@lunn.ch>
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
In-Reply-To: <20170618145305.GA4025@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Sunday, June 18, 2017 3:53 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 2/8] net: hns3: Add support of the
> HNAE3 framework
> 
> On Wed, Jun 14, 2017 at 12:10:29AM +0100, Salil Mehta wrote:
> > This patch adds the support of the HNAE3 (Hisilicon Network
> > Acceleration Engine 3) framework support to the HNS3 driver.
> >
> > Framework facilitates clients like ENET(HNS3 Ethernet Driver), RoCE
> > and user-space Ethernet drivers (like ODP etc.) to register with
> HNAE3
> > devices and their associated operations.
> 
> checkpatch throws out one warning in this file
> 
> CHECK: Comparison to NULL could be written "pos"
> #3508: FILE:
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h:572:
> +      for (pos = (head).ring; pos != NULL; pos = pos->next)
> 
> This one seems valid. Not all checkpatch warnings are.
Agreed and fixed in V4 patch.

Thanks
Salil
> 
>      Andrew

From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sat, 17 Jun 2017 11:10:32 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C24@FRAEML521-MBS.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-7-salil.mehta@huawei.com>
 <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A2554@FRAEML521-MBX.china.huawei.com>
 <20170613224042.GF15847@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A26E1@FRAEML521-MBX.china.huawei.com>
 <20170614011022.GE23384@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614011022.GE23384@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 2:10 AM
> To: Salil Mehta
> Cc: Florian Fainelli; davem@davemloft.net; Zhuangyuzeng (Yisen);
> huangdaode; lipeng (Y); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
> Ethernet driver for hip08 SoC
> 
> > Since I would be touching the core, lots of drivers will get impacted
> and will
> > have to wait till everyone gives clean signal. This will impact our
> internal
> > deadlines. But as I said I am eager to cooperate & contribute :)
> 
> Just as an FYI.
> 
> Your internal deadlines are irrelevant. We will reject your patches
> until we are happy with it. We probably won't accept a hack around a
> core feature limitation. We will want you to fix the core limitation
> and then do it right in the driver.
> 
>     Andrew

We are dropping the support of C45 in our driver till we fix the issue
just commented upon. I will try to fix this issue and would soon float
a  separate patch for that. Later, we shall re-introduce the support of
C45 in our HNS3 driver once the PHY core fix has been reviewed and accepted.

Thanks
Salil

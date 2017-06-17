From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 17 Jun 2017 11:18:49 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C54@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-3-salil.mehta@huawei.com>
 <20170614013750.GG23384@lunn.ch>
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
In-Reply-To: <20170614013750.GG23384@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 2:38 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 2/8] net: hns3: Add support of the
> HNAE3 framework
> 
> On Wed, Jun 14, 2017 at 12:10:29AM +0100, Salil Mehta wrote:
> > +static int __init hnae3_init(void)
> > +{
> > +	return 0;
> > +}
> > +
> 
> ..
> 
> > +subsys_initcall(hnae3_init);
> 
> And the point of this is?
> 
>     Andrew
This looks weird but not sure how we could have made sure HNAE is available before other
2 drivers could have loaded. Changing into module_init() means two other modules (dependent
upon hnae) if loaded first will experience load time linking problems. Do you think this
is okay? 

Thanks
Salil

From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V3 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 22 Jul 2017 23:32:21 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CC4F@FRAEML521-MBX.china.huawei.com>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-3-salil.mehta@huawei.com>
 <20170618150203.GB4025@lunn.ch>
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
In-Reply-To: <20170618150203.GB4025@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,
> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Sunday, June 18, 2017 4:02 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V3 net-next 2/8] net: hns3: Add support of the
> HNAE3 framework
> 
> > +static int __init hnae3_init(void)
> > +{
> > +	return 0;
> > +}
> > +
> > +static void __exit hnae3_exit(void)
> > +{
> > +}
> > +
> > +module_init(hnae3_init);
> > +module_exit(hnae3_exit);
> 
> I think init and exit functions are optional. Since your's don't do
> anything useful, please try without them.
Yes, you were right. Removed in V4 patch. 

Thanks
Salil
> 
> 	 Andrew

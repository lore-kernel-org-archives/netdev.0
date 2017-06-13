From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 8/9] net: hns3: Add support of debugfs
 interface to HNS3 driver
Date: Tue, 13 Jun 2017 17:16:06 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A1BBB@FRAEML521-MBX.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-9-salil.mehta@huawei.com>
 <BY2PR0701MB2005750A49D78C63B4B4A6B18DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
 <20170610163535.GC26740@lunn.ch>
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
To: Andrew Lunn <andrew@lunn.ch>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170610163535.GC26740@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Saturday, June 10, 2017 5:36 PM
> To: Mintz, Yuval
> Cc: Salil Mehta; davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode;
> lipeng (Y); mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next 8/9] net: hns3: Add support of debugfs
> interface to HNS3 driver
> 
> On Sat, Jun 10, 2017 at 12:51:57PM +0000, Mintz, Yuval wrote:
> > > This adds the support of the debugfs interface to the driver for
> debugging
> > > purposes.
> >
> > > +const struct  hclge_support_cmd  support_cmd[] = {
> > > +	{"send cmd", 8, hclge_dbg_send,
> > > +		"opcode flag data0 data1 data2 data3 data4 data5"},
> > > +	{"help", 4, hclge_dbg_usage, "no option"}, };
> >
> > Is there an actual description of what this does? Or is it simply a
> huge backdoor?
> 
> It looks like a huge backdoor to the chip.
> 
> It is O.K. to have such a patch internally for your own development
> work, but it should not be submitted for mainline.
> 
> NACK
> 
> 	Andrew
I will drop this debugfs patch for now.

Thanks
Salil

From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 8/9] net: hns3: Add support of debugfs
 interface to HNS3 driver
Date: Tue, 13 Jun 2017 17:14:29 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A1BA4@FRAEML521-MBX.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-9-salil.mehta@huawei.com>
 <BY2PR0701MB2005750A49D78C63B4B4A6B18DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0701MB2005750A49D78C63B4B4A6B18DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HI Yuval,

> -----Original Message-----
> From: Mintz, Yuval [mailto:Yuval.Mintz@cavium.com]
> Sent: Saturday, June 10, 2017 1:52 PM
> To: Salil Mehta; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: RE: [PATCH net-next 8/9] net: hns3: Add support of debugfs
> interface to HNS3 driver
> 
> > This adds the support of the debugfs interface to the driver for
> debugging
> > purposes.
> 
> > +const struct  hclge_support_cmd  support_cmd[] = {
> > +	{"send cmd", 8, hclge_dbg_send,
> > +		"opcode flag data0 data1 data2 data3 data4 data5"},
> > +	{"help", 4, hclge_dbg_usage, "no option"}, };
> 
> Is there an actual description of what this does? Or is it simply a
> huge backdoor?
Yes, I understand it has been coded in haste to assist in debugging
of the driver. Yes, there is a format to it but needs bit of work
I guess, otherwise it will be like opening pandoras box. For now, I will drop
this debugfs patch and later will push with proper explanation of its
need and interface.

Thanks
Salil

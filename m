From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 8/9] net: hns3: Add support of debugfs interface
 to HNS3 driver
Date: Sat, 10 Jun 2017 18:35:35 +0200
Message-ID: <20170610163535.GC26740@lunn.ch>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-9-salil.mehta@huawei.com>
 <BY2PR0701MB2005750A49D78C63B4B4A6B18DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Salil Mehta <salil.mehta@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BY2PR0701MB2005750A49D78C63B4B4A6B18DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2017 at 12:51:57PM +0000, Mintz, Yuval wrote:
> > This adds the support of the debugfs interface to the driver for debugging
> > purposes.
> 
> > +const struct  hclge_support_cmd  support_cmd[] = {
> > +	{"send cmd", 8, hclge_dbg_send,
> > +		"opcode flag data0 data1 data2 data3 data4 data5"},
> > +	{"help", 4, hclge_dbg_usage, "no option"}, };
> 
> Is there an actual description of what this does? Or is it simply a huge backdoor?

It looks like a huge backdoor to the chip.

It is O.K. to have such a patch internally for your own development
work, but it should not be submitted for mainline.

NACK

	Andrew

From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sun, 18 Jun 2017 17:02:03 +0200
Message-ID: <20170618150203.GB4025@lunn.ch>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-3-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-3-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int __init hnae3_init(void)
> +{
> +	return 0;
> +}
> +
> +static void __exit hnae3_exit(void)
> +{
> +}
> +
> +module_init(hnae3_init);
> +module_exit(hnae3_exit);

I think init and exit functions are optional. Since your's don't do
anything useful, please try without them.

	 Andrew

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 03/10] net: hns: add uc match for debug ports
Date: Mon, 21 Mar 2016 11:40:55 -0400 (EDT)
Message-ID: <20160321.114055.845640249977716034.davem@davemloft.net>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
	<1458558401-190165-4-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yankejian@huawei.com, huangdaode@hisilicon.com,
	salil.mehta@huawei.com, lisheng011@huawei.com,
	lipeng321@huawei.com, liguozhu@huawei.com, arnd@arndb.de,
	xieqianqian@huawei.com, andrew@lunn.ch, ivecera@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458558401-190165-4-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 21 Mar 2016 19:06:34 +0800

> +	(void)hns_mac_set_promisc(mac_cb, (u8)!!en);

This cast to void is unnecssary.

> +static void hns_gmac_set_uc_match(void *mac_drv, u16 en)
> +{
> +	struct mac_driver *drv = (struct mac_driver *)mac_drv;

Casts from void pointers are unnecessary.

> +{
> +	struct mac_driver *drv = (struct mac_driver *)mac_drv;

Likewise.

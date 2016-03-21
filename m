From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 01/10] net: hns: bug fix about ping6
Date: Mon, 21 Mar 2016 11:39:24 -0400 (EDT)
Message-ID: <20160321.113924.1745428836278929494.davem@davemloft.net>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
	<1458558401-190165-2-git-send-email-Yisen.Zhuang@huawei.com>
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
In-Reply-To: <1458558401-190165-2-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 21 Mar 2016 19:06:32 +0800

> From: Kejian Yan <yankejian@huawei.com>
> 
> The current upstreaming code fails to ping other IPv6 net device, because
> the enet receives the multicast packets with the src mac addr whick is the
                                                                ^^^^^

"which"

> @@ -670,6 +671,14 @@ out_bnum_err:
>  		return -EFAULT;
>  	}
>  
> +	/* filter out multicast pkt with the same src mac as this port */
> +	eh = (struct ethhdr *)skb->data;

Please use the "eth_hdr()" helper.

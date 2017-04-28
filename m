From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: hns: fix ethtool_get_strings overflow in hns
 driver
Date: Fri, 28 Apr 2017 16:10:50 -0400 (EDT)
Message-ID: <20170428.161050.111916772197901326.davem@davemloft.net>
References: <20170427141816.301212-1-lixiaoping3@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, lipeng321@huawei.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, mbrugger@suse.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: lixiaoping3@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170427141816.301212-1-lixiaoping3@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Timmy Li <lixiaoping3@huawei.com>
Date: Thu, 27 Apr 2017 22:18:16 +0800

> @@ -672,7 +672,7 @@ static void hns_gmac_get_strings(u32 stringset, u8 *data)
>  
>  static int hns_gmac_get_sset_count(int stringset)
>  {
> -	if (stringset == ETH_SS_STATS)
> +	if ((stringset == ETH_SS_STATS) || (stringset == ETH_SS_PRIV_FLAGS))

Excessive parenthesis, please fix this in your entire patch.

Thank you.

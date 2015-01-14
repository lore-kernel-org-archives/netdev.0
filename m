From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v12 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 14 Jan 2015 12:22:20 +0800
Message-ID: <54B5EEFC.5020902@huawei.com>
References: <1421140290-5492-1-git-send-email-dingtianhong@huawei.com>	<1421140290-5492-4-git-send-email-dingtianhong@huawei.com> <20150113.230611.375062426344934847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <robh+dt@kernel.org>, <grant.likely@linaro.org>,
	<agraf@suse.de>, <sergei.shtylyov@cogentembedded.com>,
	<linux-arm-kernel@lists.infradead.org>, <eric.dumazet@gmail.com>,
	<xuwei5@hisilicon.com>, <zhangfei.gao@linaro.org>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux@arm.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:17883 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbbANEWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 23:22:44 -0500
In-Reply-To: <20150113.230611.375062426344934847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/14 12:06, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Tue, 13 Jan 2015 17:11:30 +0800
> 
>> +static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
>> +{
>> +	struct hip04_priv *priv = netdev_priv(ndev);
>> +	int i;
>> +
>> +	priv->tx_desc = dma_alloc_coherent(d,
>> +			TX_DESC_NUM * sizeof(struct tx_desc),
>> +			&priv->tx_desc_dma, GFP_KERNEL);
> 
> When a function call spans multiple lines, the arguments on the
> second and subsequent lines should start at the first column
> after the openning parenthesis of the function call.
> 
> If you are only using TAB characters, your indentation is likely
> to be incorrect.
> 

Sorry for the mistake.

>> +	/*
>> +	 * BQL will try to keep the TX queue as short as possible, but it can't
>> +	 * be faster than tx_coalesce_usecs, so we need a fast timeout here,
>> +	 * but also long enough to gather up enough frames to ensure we don't
>> +	 * get more interrupts than necessary.
>> +	 * 200us is enough for 16 frames of 1500 bytes at gigabit ethernet rate
>> +	 */
> 
> Comments in the networking should be:
> 
> 	/* Formatted
> 	 * like this.
> 	 */
> 

yes.
>> +	priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
>> +	if (priv->phy_node) {
>> +		priv->phy = of_phy_connect(ndev, priv->phy_node,
>> +			&hip04_adjust_link, 0, priv->phy_mode);
> 
> Please align the arguments to this function call correctly, as
> per above.
> 
Ok, I will check them again.

Ding

> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 

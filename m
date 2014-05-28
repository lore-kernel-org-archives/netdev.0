From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH v2 2/2] net: hisilicon: add hix5hd2 mac driver
Date: Wed, 28 May 2014 13:48:18 +0800
Message-ID: <538578A2.7060600@linaro.org>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org> <1401194667-14445-3-git-send-email-zhangfei.gao@linaro.org> <20140527130236.GA26163@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:37672 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbaE1FsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 01:48:24 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so10423396pab.15
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 22:48:24 -0700 (PDT)
In-Reply-To: <20140527130236.GA26163@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/27/2014 09:02 PM, Tobias Klauser wrote:
> On 2014-05-27 at 14:44:27 +0200, Zhangfei Gao <zhangfei.gao@linaro.org> wrote:
>
>> +static struct net_device_stats *hix5hd2_net_get_stats(struct net_device *dev)
>> +{
>> +	return &dev->stats;
>> +}
>
> This function can be omitted, since it corresponds to the default
> behavior if neither .ndo_get_stats or .ndo_get_stats64 is set.
>
>> +
>> +static const struct net_device_ops hix5hd2_netdev_ops = {
>> +	.ndo_open		= hix5hd2_net_open,
>> +	.ndo_stop		= hix5hd2_net_close,
>> +	.ndo_start_xmit		= hix5hd2_net_xmit,
>> +	.ndo_tx_timeout		= hix5hd2_net_timeout,
>> +	.ndo_set_mac_address	= hix5hd2_net_set_mac_address,
>> +	.ndo_get_stats		= hix5hd2_net_get_stats,
>
> Thus the line above can then be omitted as well.

Thanks Tobias.

Have double checked dev_get_stats, the .ndo_get_stats can be removed here.
Thanks for the remainder.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] net: hisilicon: add hix5hd2 mac driver
Date: Fri, 06 Jun 2014 01:24:24 -0700 (PDT)
Message-ID: <20140606.012424.2191719134344576181.davem@davemloft.net>
References: <1401774577-16683-1-git-send-email-zhangfei.gao@linaro.org>
	<1401774577-16683-3-git-send-email-zhangfei.gao@linaro.org>
	<20140606081917.GD31915@ulmo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zhangfei.gao@linaro.org, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbaFFIY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 04:24:28 -0400
In-Reply-To: <20140606081917.GD31915@ulmo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <thierry.reding@gmail.com>
Date: Fri, 6 Jun 2014 10:19:18 +0200

> On Tue, Jun 03, 2014 at 01:49:37PM +0800, Zhangfei Gao wrote:
> [...]
>> diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
>> new file mode 100644
>> index 0000000..e942173
>> --- /dev/null
>> +++ b/drivers/net/ethernet/hisilicon/Kconfig
>> @@ -0,0 +1,27 @@
>> +#
>> +# HISILICON device configuration
>> +#
>> +
>> +config NET_VENDOR_HISILICON
>> +	bool "Hisilicon devices"
>> +	default y
> 
> Can this default please be dropped? It's annoying because it will cause
> this driver to be built for *every* ARM kernel by default, whether or
> not that hardware is available on a given board.

People mistakedly say this every time, this config option is not for
the driver, it's a VENDOR guard.

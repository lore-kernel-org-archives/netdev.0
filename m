From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Fri, 04 Apr 2014 23:40:24 +0800
Message-ID: <533ED268.9090502@linaro.org>
References: <1396624597-390-1-git-send-email-zhangfei.gao@linaro.org>	<1396624597-390-3-git-send-email-zhangfei.gao@linaro.org> <20140404.113010.1212333214715849484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:54460 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbaDDPkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 11:40:33 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so3579174pbb.8
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 08:40:32 -0700 (PDT)
In-Reply-To: <20140404.113010.1212333214715849484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/04/2014 11:30 PM, David Miller wrote:
> From: Zhangfei Gao <zhangfei.gao@linaro.org>
> Date: Fri,  4 Apr 2014 23:16:36 +0800
>
>> +config HIP04_ETH
>> +	tristate "HISILICON P04 Ethernet support"
>> +	select NET_CORE
>> +	select PHYLIB
>> +	select MARVELL_PHY
>> +	select MFD_SYSCON
>> +	---help---
>> +	  If you wish to compile a kernel for a hardware with hisilicon p04 SoC and
>> +	  want to use the internal ethernet then you should answer Y to this.
>
> Selecting NET_CORE makes no sense, if it's not set this driver's
> Kconfig file won't even be considered.
>

Thanks Daivd, could I update following this thread first.

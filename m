From: Daode Huang <huangdaode@hisilicon.com>
Subject: Re: [PATCH v2 net-next 1/9] MAINTAINERS: add maintainers for hns
 driver
Date: Fri, 1 Jul 2016 10:15:12 +0800
Message-ID: <5775D230.6040103@hisilicon.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1467271509-63162-2-git-send-email-Yisen.Zhuang@huawei.com>
 <1467283701.24287.137.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<lipeng321@huawei.com>, <xieqianqian@huawei.com>, <arnd@arndb.de>,
	<andrew@lunn.ch>, <xypron.glpk@gmx.de>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>, <davem@davemloft.net>,
	<salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5584 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbcGACUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 22:20:13 -0400
In-Reply-To: <1467283701.24287.137.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/6/30 18:48, Joe Perches wrote:
> On Thu, 2016-06-30 at 15:25 +0800, Yisen Zhuang wrote:
>> From: Daode Huang <huangdaode@hisilicon.com>
>>
>> This patch adds maintainers for hisilicon network subsystem driver
> []
>> diff --git a/MAINTAINERS b/MAINTAINERS
> []
>> @@ -5421,6 +5421,15 @@ F:	include/uapi/linux/if_hippi.h
>>   F:	net/802/hippi.c
>>   F:	drivers/net/hippi/
>>   
>> +HISILICON NETWORK SUBSYSTEM DRIVER
>> +M:	Yisen Zhuang <yisen.zhuang@huawei.com>
>> +M:	Salil Mehta <salil.mehta@huawei.com>
>> +L:	netdev@vger.kernel.org
>> +W:	http://www.hisilicon.com
>> +S:	Maintained
>> +F:	drivers/net/ethernet/hisilicon/*
> >From MAINTAINERS:
>
> 	F: Files and directories with wildcard patterns.
> 	   A trailing slash includes all files and subdirectory files.
> 	   F:	drivers/net/	all files in and below drivers/net
> 	   F:	drivers/net/*	all files in drivers/net, but not below
> 	   F:	*/net/*		all files in "any top level directory"/net
> 	   One pattern per line.  Multiple F: lines acceptable.
>
> So this pattern with the trailing /* matches only:
>
> drivers/net/ethernet/hisilicon/Kconfig
> drivers/net/ethernet/hisilicon/Makefile
> drivers/net/ethernet/hisilicon/hip04_eth.c
> drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
>
> and not any file in drivers/net/ethernet/hisilicon/hns/
>
> Is that what you want?

We will maintain all files in hisilicon and any directory below it.
will fix it in next submit.

Thanks

> using
>
> F:	drivers/net/ethernet/hisilicon/
>
> matches all files in hisilicon and any directory below it.
>
>
>
> .
>

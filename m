From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take2
Date: Tue, 03 Jul 2007 09:11:09 -0400
Message-ID: <468A4AED.7080907@garzik.org>
References: <20070619183956.F224.MOKUNO@sm.sony.co.jp> <4688EFD1.1060805@garzik.org> <20070703194416.91C5.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59812 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496AbXGCNLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 09:11:14 -0400
In-Reply-To: <20070703194416.91C5.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masakazu Mokuno wrote:
>>> --- a/drivers/net/Makefile
>>> +++ b/drivers/net/Makefile
>>> @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
>>>  obj-$(CONFIG_BNX2) += bnx2.o
>>>  spidernet-y += spider_net.o spider_net_ethtool.o
>>>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
>>> +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
>>> +ps3_gelic-objs += gelic_net.o
>>>  obj-$(CONFIG_TC35815) += tc35815.o
>>>  obj-$(CONFIG_SKGE) += skge.o
>>>  obj-$(CONFIG_SKY2) += sky2.o
>>> --- /dev/null
>>> +++ b/drivers/net/gelic_net.c
>> The patch does not reflect the new name...
> 
> The driver's module name is 'ps3_gelic.ko' and the souce file names are
> 'gelic_net.{c,h}'.  As Geoff Levand said in the mail dated June 16, we
> have plan to add wireless support and its file name would be gelic_wireless.c.
> If this support added, the make file would be:
> 
>   obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
>   gelic-$(CONFIG_GELIC_WIRELESS) += gelic_wireless.o
>   ps3_gelic-objs += gelic_net.o $(gelic-y)


For single-file modules, the source file prefix should match the output 
file prefix.

No Linux driver does it any other way.  It leads to confusion.

	Jeff



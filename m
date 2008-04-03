From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 1/5] fec: kill warnings
Date: Thu, 3 Apr 2008 09:44:52 +0200
Message-ID: <20080403074452.GB778@Chamillionaire.breakpoint.cc>
References: <20080402204417.597098190@linutronix.de> <20080402210103.046161355@linutronix.de> <47F47998.1080702@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:59210 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759026AbYDCHo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 03:44:59 -0400
Content-Disposition: inline
In-Reply-To: <47F47998.1080702@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Greg Ungerer | 2008-04-03 16:30:48 [+1000]:

> Hi Sebastian,
>
> Sebastian Siewior wrote:
>> linux-2.6-mk68/drivers/net/fec.c: In function 'fec_enet_module_init':
>> linux-2.6-mk68/drivers/net/fec.c:2627: warning: unused variable 'j'
>> linux-2.6-mk68/drivers/net/fec.c: At top level:
>> linux-2.6-mk68/drivers/net/fec.c:2136: warning: 'mii_link_interrupt' 
>> defined but not used
>> Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
>> --- a/drivers/net/fec.c
>> +++ b/drivers/net/fec.c
>> @@ -67,6 +67,11 @@
>>  #define	FEC_MAX_PORTS	1
>>  #endif
>>  +#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || 
>> defined(CONFIG_M528x) || \
>> +	defined(CONFIG_M520x) || defined(CONFIG_M532x)
>> +#define DONT_NEED_mii_link_interrupt
>
> I think using normal positive logic would be clearer, eg:
>
>   HAVE_mii_link_interupt
Will do it.

> Very few of the boards I have come across with the FEC silicon
> actually hook up the MII interrupt, so the list of devices that
> have it will be smaller.
This doesn't mean we get rid of it, does it? :)

>
> Regards
> Greg
Sebastian

From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 1/5] fec: kill warnings
Date: Thu, 03 Apr 2008 19:30:30 +1000
Message-ID: <47F4A3B6.9030306@snapgear.com>
References: <20080402204417.597098190@linutronix.de> <20080402210103.046161355@linutronix.de> <47F47998.1080702@snapgear.com> <20080403074452.GB778@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted02.westnet.com.au ([203.10.1.213]:52845 "EHLO
	hosted02.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757209AbYDCJbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 05:31:00 -0400
In-Reply-To: <20080403074452.GB778@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Siewior wrote:
> * Greg Ungerer | 2008-04-03 16:30:48 [+1000]:
> 
>> Hi Sebastian,
>>
>> Sebastian Siewior wrote:
>>> linux-2.6-mk68/drivers/net/fec.c: In function 'fec_enet_module_init':
>>> linux-2.6-mk68/drivers/net/fec.c:2627: warning: unused variable 'j'
>>> linux-2.6-mk68/drivers/net/fec.c: At top level:
>>> linux-2.6-mk68/drivers/net/fec.c:2136: warning: 'mii_link_interrupt' 
>>> defined but not used
>>> Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
>>> --- a/drivers/net/fec.c
>>> +++ b/drivers/net/fec.c
>>> @@ -67,6 +67,11 @@
>>>  #define	FEC_MAX_PORTS	1
>>>  #endif
>>>  +#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || 
>>> defined(CONFIG_M528x) || \
>>> +	defined(CONFIG_M520x) || defined(CONFIG_M532x)
>>> +#define DONT_NEED_mii_link_interrupt
>> I think using normal positive logic would be clearer, eg:
>>
>>   HAVE_mii_link_interupt
> Will do it.
> 
>> Very few of the boards I have come across with the FEC silicon
>> actually hook up the MII interrupt, so the list of devices that
>> have it will be smaller.
> This doesn't mean we get rid of it, does it? :)

No, no. It nice for those that do it.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
SnapGear -- a Secure Computing Company      PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com

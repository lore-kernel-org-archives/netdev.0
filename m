From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC] gianfar: low gigabit throughput
Date: Tue, 6 May 2008 15:29:06 -0500
Message-ID: <E82C3C5F-0D93-4190-ADDC-3FA37D13E250@freescale.com>
References: <20080506192008.GA30148@polina.dev.rtsoft.ru> <4820BA72.3090903@hp.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48928 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbYEFUa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:30:27 -0400
In-Reply-To: <4820BA72.3090903@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> I've tried to tune gianfar driver in various ways... and it gave
>> some positive results with this patch:
>> diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
>> index fd487be..b5943f9 100644
>> --- a/drivers/net/gianfar.h
>> +++ b/drivers/net/gianfar.h
>> @@ -123,8 +123,8 @@ extern const char gfar_driver_version[];
>> #define GFAR_10_TIME    25600
>>  #define DEFAULT_TX_COALESCE 1
>> -#define DEFAULT_TXCOUNT	16
>> -#define DEFAULT_TXTIME	21
>> +#define DEFAULT_TXCOUNT	80
>> +#define DEFAULT_TXTIME	105
>>  #define DEFAULT_RXTIME	21
>
> No ethtool coalescing tuning support for gianfar?-)

Yeah, there's coalescing tuning in gianfar.

Anton, those numbers aren't too surprising on a 400 MHz machine, I  
think.  But I'd be happy to see any analysis on performance  
bottlenecks in the driver.  And patches to fix those bottlenecks are  
even better!  :)

Andy

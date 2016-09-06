From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] smsc95xx: Add register define
Date: Tue, 06 Sep 2016 13:27:38 -0700 (PDT)
Message-ID: <20160906.132738.1194681585026078241.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D409100A1@CHN-SV-EXMX02.mchp-main.com>
        <1472848801.22931.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Woojung.Huh@microchip.com, steve.glendinning@shawell.net,
        netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753186AbcIFU1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:27:44 -0400
In-Reply-To: <1472848801.22931.7.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 02 Sep 2016 13:40:01 -0700

> On Fri, 2016-09-02 at 20:34 +0000, Woojung.Huh@microchip.com wrote:
>> From: Woojung Huh <woojung.huh@microchip.com>
>> 
>> Add STRAP_STATUS defines.
> []
>> diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
> []
>> @@ -144,6 +144,14 @@
>>  
>>  #define BURST_CAP			(0x38)
>>  
>> +#define	STRAP_STATUS			(0x3C)
>> +#define	STRAP_STATUS_PWR_SEL_		(0x00000020)
>> +#define	STRAP_STATUS_AMDIX_EN_		(0x00000010)
>> +#define	STRAP_STATUS_PORT_SWAP_		(0x00000008)
>> +#define	STRAP_STATUS_EEP_SIZE_		(0x00000004)
>> +#define	STRAP_STATUS_RMT_WKP_		(0x00000002)
>> +#define	STRAP_STATUS_EEP_DISABLE_	(0x00000001)
> 
> Using BIT would be more common.
> 
> Ending the #defines with an underscore is just odd
> and unappealing.

But that's what the rest of this file is doing already.

If we want to change this, it's a separate follow-up change.

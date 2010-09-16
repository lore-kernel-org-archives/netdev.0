From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Handle rxfifo errors on 8168 chips
Date: Wed, 15 Sep 2010 19:33:45 -0700 (PDT)
Message-ID: <20100915.193345.184829695.davem@davemloft.net>
References: <1284501431-23263-1-git-send-email-mjg@redhat.com>
	<20100915222719.GA13385@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjg@redhat.com, netdev@vger.kernel.org, jglisse@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350Ab0IPCd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 22:33:26 -0400
In-Reply-To: <20100915222719.GA13385@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 16 Sep 2010 00:27:19 +0200

> Matthew Garrett <mjg@redhat.com> :
> [...]
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>> index 078bbf4..a0da4a1 100644
>> --- a/drivers/net/r8169.c
>> +++ b/drivers/net/r8169.c
> [...]
>> @@ -4625,8 +4625,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>>  		}
>>  
>>  		/* Work around for rx fifo overflow */
>> -		if (unlikely(status & RxFIFOOver) &&
>> -		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
>> +		if (unlikely(status & RxFIFOOver)) {
>>  			netif_stop_queue(dev);
>>  			rtl8169_tx_timeout(dev);
>>  			break;
> 
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> Realtek's driver does something similar with the revision RTL_GIGA_MAC_VER_11
> of the 8168.

Applied, thanks everyone.

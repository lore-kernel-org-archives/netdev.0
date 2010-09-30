From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] de2104x: remove experimental status
Date: Wed, 29 Sep 2010 19:48:05 -0700 (PDT)
Message-ID: <20100929.194805.68142212.davem@davemloft.net>
References: <201009282046.21279.linux@rainbow-software.org>
	<4CA23963.8040409@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA23963.8040409@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 28 Sep 2010 14:52:19 -0400

> On 09/28/2010 02:46 PM, Ondrej Zary wrote:
>> It should be ready after 8 years...remove the experimental dependency.
>>
>> Signed-off-by: Ondrej Zary<linux@rainbow-software.org>
>>
>> --- linux-2.6.36-rc3-/drivers/net/tulip/Kconfig 2010-08-29
>> --- 17:36:04.000000000 +0200
>> +++ linux-2.6.36-rc3/drivers/net/tulip/Kconfig 2010-09-28
>> 19:49:46.000000000 +0200
>> @@ -11,8 +11,8 @@ menuconfig NET_TULIP
>>   if NET_TULIP
>>
>>   config DE2104X
>> -	tristate "Early DECchip Tulip (dc2104x) PCI support (EXPERIMENTAL)"
>> -	depends on PCI&&  EXPERIMENTAL
>> +	tristate "Early DECchip Tulip (dc2104x) PCI support"
>> +	depends on PCI
>>   	select CRC32
>>   	---help---
>>   	  This driver is developed for the SMC EtherPower series Ethernet
> 
> Well...  it's not the years, it's the quality...  which I think has
> been sufficiently increased.
> 
> Acked-by: Jeff Garzik <jgarzik@redhat.com>

Also applied to net-next-2.6, thanks.

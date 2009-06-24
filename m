From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: let SJA1000 driver depend on HAS_IOMEM
Date: Wed, 24 Jun 2009 08:52:38 +0200
Message-ID: <4A41CD36.8030202@hartkopp.net>
References: <20090623073120.GA5955@osiris.boeblingen.de.ibm.com> <4A412C53.8050607@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:32277 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbZFXGwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 02:52:41 -0400
In-Reply-To: <4A412C53.8050607@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Heiko Carstens wrote:


>> Index: linux-2.6/drivers/net/can/Kconfig
>> ===================================================================
>> --- linux-2.6.orig/drivers/net/can/Kconfig
>> +++ linux-2.6/drivers/net/can/Kconfig
>> @@ -36,7 +36,7 @@ config CAN_CALC_BITTIMING
>>  	  If unsure, say Y.
>>  
>>  config CAN_SJA1000
>> -	depends on CAN_DEV
>> +	depends on CAN_DEV && HAS_IOMEM
>>  	tristate "Philips SJA1000"
>>  	---help---
>>  	  Driver for the SJA1000 CAN controllers from Philips or NXP
> 
> Hm, this Kconfig entry is not directly responsible for building
> sja1000_platform.o. It builds sja1000.o, which does not rely on
> HAS_IOMEM. It should be added to "config CAN_SJA1000_PLATFORM" instead.

Hi Wolfgang,

the question is, if we should add HAS_IOMEM to almost every SJA1000 depended
driver like SJA1000_PLATFORM, SJA1000_OF_PLATFORM, EMS_PCI and KVASER_PCI ???

Is it possible to have a support for the SJA1000 that does *not* depend on
HAS_IOMEM?

Regards,
Oliver

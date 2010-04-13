From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: add support for reporting 5GT/s
 during probe on PCIe Gen2
Date: Tue, 13 Apr 2010 02:58:57 -0700 (PDT)
Message-ID: <20100413.025857.38087733.davem@davemloft.net>
References: <20100409195246.30654.40319.stgit@localhost.localdomain>
	<1270857256.2176.37.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45834
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751679Ab0DMJ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:58:53 -0400
In-Reply-To: <1270857256.2176.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 10 Apr 2010 00:54:16 +0100

> On Fri, 2010-04-09 at 12:52 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> 
>> This change corrects the fact that we were not reporting Gen2 link speeds
>> when we were in fact connected at Gen2 rates.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>> 
>>  drivers/net/igb/e1000_defines.h |    3 +++
>>  drivers/net/igb/e1000_mac.c     |   19 ++++++++++++++++---
>>  drivers/net/igb/igb_main.c      |    1 +
>>  3 files changed, 20 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
>> index 31d24e0..8e440e8 100644
>> --- a/drivers/net/igb/e1000_defines.h
>> +++ b/drivers/net/igb/e1000_defines.h
>> @@ -615,6 +615,9 @@
>>  
>>  #define PCIE_LINK_WIDTH_MASK         0x3F0
>>  #define PCIE_LINK_WIDTH_SHIFT        4
>> +#define PCIE_LINK_SPEED_MASK         0x0F
>> +#define PCIE_LINK_SPEED_2500         0x01
>> +#define PCIE_LINK_SPEED_5000         0x02
>>  #define PCIE_DEVICE_CONTROL2_16ms    0x0005
> [...]
> 
> These generic definitions belong in <linux/pci_regs.h>; in fact some of
> it is already there.

Agreed, please put these in the PCI header file.

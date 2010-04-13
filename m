From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] can: Add esd board support to plx_pci CAN driver
Date: Tue, 13 Apr 2010 01:23:47 -0700 (PDT)
Message-ID: <20100413.012347.156262210.davem@davemloft.net>
References: <201004071309.56518.matthias.fuchs@esd.eu>
	<4BC1E1C6.1050405@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthias.fuchs@esd.eu, netdev@vger.kernel.org,
	Socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37421
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307Ab0DMIXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:23:43 -0400
In-Reply-To: <4BC1E1C6.1050405@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sun, 11 Apr 2010 16:50:46 +0200

> Matthias Fuchs wrote:
>> This patch adds support for SJA1000 based PCI CAN interface cards
>> from electronic system design gmbh.
>> 
>> Some changes have been done on the common code:
>>  - esd boards must not have the 2nd local interupt enabled (PLX9030/9050)
>>  - a new path for PLX9056/PEX8311 chips has been added
>>  - new plx9056 reset function has been implemented
>>  - struct plx_card_info got a reset function entry
>> 
>> In detail the following additional boards are now supported:
>> 
>>         CAN-PCI/200 (PCI)
>>         CAN-PCI/266 (PCI)
>>         CAN-PMC266 (PMC module)
>>         CAN-PCIe/2000 (PCI Express)
>>         CAN-CPCI/200 (Compact PCI, 3U)
>>         CAN-PCI104 (PCI104)
>> 
>> Signed-off-by: Matthias Fuchs <matthias.fuchs@esd.eu>
>> ---
>> v2:
>>  - update Kconfig
>>  - add proper plx9056 reset function
>>  - add reset function pointer to plx_card_info structure
>>  - use card's reset function in plx_pci_del_card()
> 
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied to net-next-2.6, thanks.

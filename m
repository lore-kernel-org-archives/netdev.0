From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] add Attansic L2 PCI ID
Date: Thu, 29 Mar 2007 10:11:38 -0400
Message-ID: <460BC91A.4090407@redhat.com>
References: <20070328234738.GA8042@devserv.devel.redhat.com> <460BAFB0.7000408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiong.huang@atheros.com, jacliburn@bellsouth.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35125 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643AbXC2OLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 10:11:47 -0400
In-Reply-To: <460BAFB0.7000408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Chris Snook wrote:
>> From: Chris Snook <csnook@redhat.com>
>>
>> Add PCI ID for the Attansic L2 100 Mb ethernet adapter.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
>>
>> --- linux-2.6.21-rc5.orig/include/linux/pci_ids.h    2007-03-27 
>> 23:26:50.000000000 -0400
>> +++ linux-2.6.21-rc5/include/linux/pci_ids.h    2007-03-28 
>> 15:11:03.000000000 -0400
>> @@ -2090,6 +2090,7 @@
>>  
>>  #define PCI_VENDOR_ID_ATTANSIC        0x1969
>>  #define PCI_DEVICE_ID_ATTANSIC_L1    0x1048
>> +#define PCI_DEVICE_ID_ATTANSIC_L2    0x2048
> 
> Actually you should be doing the reverse:
> 
> Remove PCI_DEVICE_ID_ATTANSIC_L1, and replace the one place that uses it 
> with the hexadecimal constant.
> 
>     Jeff

We're working on integrating the driver for the L2 chip, so it will be useful to 
symbolically distinguish between them.  For now, adding the ID serves to 
document the distinction between the L1 and L2 chips, as they're alike enough 
that an atl1 driver hacked with the new PCI ID will detect link status on the 
L2, even though it won't really work.  By getting the ID in now, we can 
distribute patches that don't touch core code and won't need to be tweaked for 
submission.

If pci_ids.h bloat is really a big deal, we can hold off until the L2 patches 
are ready, but I don't see the harm in getting this out there now.

	-- Chris

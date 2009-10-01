From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] skge: use unique IRQ name
Date: Thu, 01 Oct 2009 15:17:46 -0700 (PDT)
Message-ID: <20091001.151746.119636739.davem@davemloft.net>
References: <20091001200208.2907b8ff@leela>
	<20091001111323.260d49bf@s6510>
	<20091001.133155.53607208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752212AbZJAWR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:17:27 -0400
In-Reply-To: <20091001.133155.53607208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 01 Oct 2009 13:31:55 -0700 (PDT)

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 1 Oct 2009 11:13:23 -0700
> 
>> $ grep skge /proc/interrupts
>>  17:        169   IO-APIC-fasteoi   skge@0000:00:0a.0, eth0
> 
> Please fix this example output to match the code :-)
> 
>> +	sprintf(hw->irq_name, DRV_NAME "@pci:%s", pci_name(pdev));
> 
> Thanks!

Nevermind, I took care of this when applying your patch.

From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usbnet cdc_subset: fix issues talking to PXA gadgets
Date: Fri, 19 Jun 2009 01:07:56 -0700 (PDT)
Message-ID: <20090619.010756.193703794.davem@davemloft.net>
References: <200906190011.28320.david-b@pacbell.net>
	<20090619.002403.98174871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aric@sdgsystems.com
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751793AbZFSIHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 04:07:53 -0400
In-Reply-To: <20090619.002403.98174871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 19 Jun 2009 00:24:03 -0700 (PDT)

> From: David Brownell <david-b@pacbell.net>
> Date: Fri, 19 Jun 2009 00:11:28 -0700
> 
>> From: David Brownell <dbrownell@users.sourceforge.net>
>> 
>> The host-side CDC subset driver is binding more specifically
>> than it should ... only to PXA 210/25x/26x Linux-USB gadgets.
>> 
>> Loosen that restriction to match the gadget driver itself.
>> This helps various PXA 27x and PXA 3xx devices be happier
>> when talking to Linux hosts; and a few other gadgets too.
>> 
>> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
>> Tested-by: Aric D. Blumer <aric@sdgsystems.com>
>> ---
>> Appropriate for -stable ... behaves like a protocol bug.
> 
> Applied and queued up for -stable.

David this doesn't even compile:

  CC [M]  drivers/net/usb/cdc_subset.o
drivers/net/usb/cdc_subset.c:313:32: error: macro "USB_DEVICE_VER" requires 4 arguments, but only 2 given
drivers/net/usb/cdc_subset.c:313: error: 'USB_DEVICE_VER' undeclared here (not in a function)

There is absolutely no excuse for this, really.

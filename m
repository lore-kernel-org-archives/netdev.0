From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Remove unneeded asm header files
Date: Thu, 18 Apr 2013 13:57:01 -0400 (EDT)
Message-ID: <20130418.135701.1058528754335411103.davem@davemloft.net>
References: <1366251498-11677-1-git-send-email-festevam@gmail.com>
	<516FDF7B.10808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, gerg@uclinux.org, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: gregungerer00@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab3DRR5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 13:57:04 -0400
In-Reply-To: <516FDF7B.10808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gregungerer00@gmail.com>
Date: Thu, 18 Apr 2013 21:56:43 +1000

> Hi Fabio,
> 
> On 18/04/13 12:18, Fabio Estevam wrote:
>> From: Fabio Estevam <fabio.estevam@freescale.com>
>> 
>> There is nothing in the driver that requires asm header files.
>> 
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>> ---
>> Greg,
>> 
>> I built this for ARM and x86 (tweaking Kconfig), but I don't have a m68k 
>> toolchain installed here to test it.
>> 
>> Please build it for m68k if you have a chance. Thanks
>> 
>>  drivers/net/ethernet/freescale/fec_main.c |    7 -------
> 
> fec_main.c?  It doesn't exist in 3.9-rc7.
> Comments and tests below based on fec.c in 3.9-rc7.

That's where the driver is in net-next, which cleanups such as this
should be targetted.

From: David Miller <davem@davemloft.net>
Subject: Re: 3c509 resume from hibernation broken somewhere between 2.6.25
 and 2.6.28
Date: Fri, 06 Feb 2009 22:04:26 -0800 (PST)
Message-ID: <20090206.220426.21894163.davem@davemloft.net>
References: <200902061422.14746.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35947
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbZBGGE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 01:04:29 -0500
In-Reply-To: <200902061422.14746.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>
Date: Fri, 6 Feb 2009 14:22:13 +0100

> Hello,
> last year, I posted a patch which fixed hibernation on 3c509 cards. That was 
> back in 2.6.24. It worked fine in 2.6.25. But then I stopped using 
> hibernation (as it did not work with my new IT8212 RAID controller).
> 
> Now I fixed it and noticed that 3c509 does not wake up properly anymore (in 
> 2.6.28) - neither in PnP nor in ISA modes. ifconfig down/up makes the card 
> work again in PnP mode. However, in ISA mode, ifconfig up ends with "No such 
> device" error.
> 
> Comparing the 3c509 driver between 2.6.25 and 2.6.28, there's only some 
> statistics-related change. So the cause of the problem must be somewhere 
> else.
> 
> This patch makes the resume work in PnP mode, but it's still not enough for 
> ISA mode.

Patch applied, thank you.

Let us know if you figure out how to get the ISA case working
too :-)

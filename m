From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [RFC] 3c509: convert to isa_driver and pnp_driver v2
Date: Sat, 02 Feb 2008 15:50:25 -0500
Message-ID: <47A4D791.3050700@garzik.org>
References: <200801312012.43447.linux@rainbow-software.org> <200802021925.36552.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60295 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761212AbYBBUu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 15:50:28 -0500
In-Reply-To: <200802021925.36552.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ondrej Zary wrote:
> Hello,
> this is second version of the patch. Autoloading using udev works fine with 
> PnP card. Hibernation now works both in PnP and ISA modes. The I/O address 
> used for non-pnp ISA card detection is now not released as it's needed to 
> wake up the card.
> 
> Manual irq and transceiver settings aren't implemented yet. Operation with 
> multiple cards is not tested - I'll try 3 cards in both PnP and ISA modes. 
> There is some code that is the same in each of the 4 probe functions (isa, 
> pnp, eisa and mca), which should be probably separated into a function.
> 
> I have no EISA or MCA machine so I hope that I didn't break them.

Looks pretty good at first glance...

I'll throw it in my queue.  Want to add a signed-off-by:  ?

	Jeff




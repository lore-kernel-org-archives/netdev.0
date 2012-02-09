From: Peter Meerwald <pmeerw@pmeerw.net>
Subject: Re: [PATCH 2/2] smsc95xx: allow to re-use MAC address already
 programmed
Date: Thu, 9 Feb 2012 10:59:36 +0100 (CET)
Message-ID: <alpine.DEB.2.01.1202091038580.8085@pmeerw.net>
References: <1328699332-9024-1-git-send-email-pmeerw@pmeerw.net> <1328699332-9024-2-git-send-email-pmeerw@pmeerw.net> <20120208.152647.2150915591550944292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, danny.kukawka@bisect.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.pmeerw.net ([87.118.82.44]:51100 "EHLO pmeerw.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab2BIJ7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:59:37 -0500
In-Reply-To: <20120208.152647.2150915591550944292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

> > patch adds a module parameter which allows to keep the MAC address already 
> > set (e.g. by the boot loader) if it is valid (otherwise the MAC address is read 
> > from an optional EEPROM or randomly generated)

> No way, for the same reason as your other patch.
> Module parameters suck, use something generic.

is there a generic solution (yet)?

the goal is to support tftp-ing a kernel image from u-boot and doing 
a rootnfs mount in the kernel (with the same MAC address)

it was suggested to set the MAC address from userspace/initrd which seems 
to be a lot of overhead

I am aware of Danny Kukawka's work in a similar direction

the embedded approach would probably be to hand some board-specific 
callback to the 'network layer' in order to obtain a MAC whenever it is 
needed; this could replace/supplement random_ether_addr() found in many 
drivers

regards, p.

-- 

Peter Meerwald
+43-664-2444418 (mobile)

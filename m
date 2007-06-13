From: linux@horizon.com
Subject: Re: IC Plus Corp IC Plus IP1000
Date: 12 Jun 2007 21:57:21 -0400
Message-ID: <20070613015721.31814.qmail@science.horizon.com>
Cc: linux@horizon.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:16045 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751724AbXFMCED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 22:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

plr@udgaard.com wrote:
> I wonder if it at some time will be included in the standard Linux kernel?
> I am of course interested because my main board has it built in, so I 
> would be willing to test it.

"Me, too!"

This has been discussed sporadically for the last year, and I can confirm
that the driver source from the manufacturer's web page is starting
to suffer bit rot, but after patching the more egregious breakage
(references to <linux/config.h>, UTS_RELEASE and pci_module_init()
stop it from compiling), it works.

It doesn't even spew "eth0: excessive work at interrupt" when running
arp-scan, unlike certain in-tree drivers. :-)

I got a bit of a rude shock today after doing an emergency replacement
on a socket 939 motherboard and blandly assuring a Windows-experienced
co-worker that despite a change from nForce to VIA KT890 chipset, the
system should "just work".

One round of floppy shuffle and code-fixing later, my co-worker is
not impressed by the Linux version of "Have driver disk".  :-)


Is anyone able to push it to completion?  I have a vague idea that the
vendor lost interest.  (Should I write to Greg K-H and tell him
"Free Linux Driver Developed!"?)

I can play testing guinea-pig if needed.

Thanks!

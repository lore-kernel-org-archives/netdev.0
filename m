From: Daniel Barkalow <barkalow@iabervon.org>
Subject: Re: forcedeth problems on 2.6.20-rc6-mm3
Date: Mon, 5 Feb 2007 01:34:54 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702050124320.20138@iabervon.org>
References: <45C6BCE5.90103@shaw.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
To: Robert Hancock <hancockr@shaw.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752736AbXBEGe4@vger.kernel.org>
In-Reply-To: <45C6BCE5.90103@shaw.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 4 Feb 2007, Robert Hancock wrote:

> Something's busted with forcedeth in 2.6.20-rc6-mm3 for me relative to
> 2.6.20-rc6. There's no errors in dmesg, but it seems no packets ever get
> received and so the machine can't get an IP address. I tried reverting all the
> -mm changes to drivers/net/forcedeth.c, which didn't help. The network
> controller shares an IRQ with the USB OHCI controller which is receiving
> interrupts, so it doesn't seem like an interrupt routing problem, though I
> suppose something wierd could be happening there.

IIRC, forcedeth tries to use MSI by default. Perhaps the hardware is using 
it, but the kernel thinks enabling it didn't work? I think there's a 
module option for forcedeth to disable MSI, which might be worth a try to 
see if it has any effect.

	-Daniel
*This .sig left intentionally blank*

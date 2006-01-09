From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: [2.6.15] running tcpdump on 3c905b causes freeze (reproducable)
Date: Mon, 9 Jan 2006 15:45:22 +0100
Message-ID: <20060109144522.GB10955@vanheusden.com>
References: <20060108114305.GA32425@vanheusden.com>
	<20060109041114.6e797a9b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964785AbWAIOpZ@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060109041114.6e797a9b.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > My system freezes (crashes) when I run tcpdump on the interface
> >  connected to a 3c905b card.
> Works for me with a 3c980-TX.  I can dig out a 905b.
> Please send the exact commands which you're using to demonstrate this -
> sufficient info for me to get as close as possible to what you're doing.

The exact command is:
tcpdump -i eth1

Yes, it is that simple. Not only tcpdump gives this problem; iftop as
well.

> Have you tried enabling the NMI watchdog?  Enable CONFIG_X86_LOCAL_APIC and
> boot with `nmi_watchdog=1' on the command line, make sure that the NMI line
> of /proc/interrupts is incrementing.

I'll give it a try. I've added it to the append-line in the lilo config.
Am now compiling the kernel.


Folkert van Heusden

-- 
Try MultiTail! Multiple windows with logfiles, filtered with regular
expressions, colored output, etc. etc. www.vanheusden.com/multitail/
----------------------------------------------------------------------
Get your PGP/GPG key signed at www.biglumber.com!
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

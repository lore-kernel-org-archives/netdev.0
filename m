From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: [2.6.15] running tcpdump on 3c905b causes freeze (reproducable)
Date: Mon, 9 Jan 2006 20:37:55 +0100
Message-ID: <20060109193754.GD12673@vanheusden.com>
References: <20060108114305.GA32425@vanheusden.com>
	<20060109041114.6e797a9b.akpm@osdl.org>
	<20060109144522.GB10955@vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751258AbWAITh5@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060109144522.GB10955@vanheusden.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Have you tried enabling the NMI watchdog?  Enable CONFIG_X86_LOCAL_APIC and
> > boot with `nmi_watchdog=1' on the command line, make sure that the NMI line
> > of /proc/interrupts is incrementing.
> I'll give it a try. I've added it to the append-line in the lilo config.
> Am now compiling the kernel.

No change. Well, that is: the last message on the console now is
"setting eth1 to promiscues mode".


Folkert van Heusden

-- 
Try MultiTail! Multiple windows with logfiles, filtered with regular
expressions, colored output, etc. etc. www.vanheusden.com/multitail/
----------------------------------------------------------------------
Get your PGP/GPG key signed at www.biglumber.com!
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

From: Andrew Morton <akpm@osdl.org>
Subject: Re: [2.6.15] running tcpdump on 3c905b causes freeze (reproducable)
Date: Mon, 9 Jan 2006 22:48:21 -0800
Message-ID: <20060109224821.7a40bc69.akpm@osdl.org>
References: <20060108114305.GA32425@vanheusden.com>
	<20060109041114.6e797a9b.akpm@osdl.org>
	<20060109144522.GB10955@vanheusden.com>
	<20060109193754.GD12673@vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750856AbWAJGsk@vger.kernel.org>
To: Folkert van Heusden <folkert@vanheusden.com>
In-Reply-To: <20060109193754.GD12673@vanheusden.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folkert van Heusden <folkert@vanheusden.com> wrote:
>
> > > Have you tried enabling the NMI watchdog?  Enable CONFIG_X86_LOCAL_APIC and
> > > boot with `nmi_watchdog=1' on the command line, make sure that the NMI line
> > > of /proc/interrupts is incrementing.
> > I'll give it a try. I've added it to the append-line in the lilo config.
> > Am now compiling the kernel.
> 
> No change. Well, that is: the last message on the console now is
> "setting eth1 to promiscues mode".
> 

Did you confirm that the NMI counters in /proc/interrupts are incrementing?

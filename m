From: Christoph Hellwig <hch@lst.de>
Subject: [kdmirsch@gmx.net: Re: Bug#254910: #254910 kernel-2.4.22-2-686 and higher: Incorrect UDP checksum for DNS request with 8139too driver]
Date: Mon, 30 Aug 2004 18:15:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830161508.GA19759@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----- Forwarded message from Klaus-Dieter Mirsch <kdmirsch@gmx.net> -----

Date: Mon, 30 Aug 2004 18:13:10 +0200
From: Klaus-Dieter Mirsch <kdmirsch@gmx.net>
Subject: Re: Bug#254910: #254910 kernel-2.4.22-2-686 and higher: Incorrect
	UDP checksum for DNS request with 8139too driver
To: Christoph Hellwig <hch@lst.de>, 254910-quiet@bugs.debian.org
X-Mailer: Ximian Evolution 1.4.6 

Hi Christoph,

now after the olmypic games are over I'm able to do something else than
watch TV in my leisure time. (-; So sorry for answering late.

The bug is reproduciable and has nothing, I repeat, nothing to do with
Cisco VPN 3000 Client Software. 

For me this bug is important because without a working DNS over VPN I
cannot work for my company on the other hand 2.4.18 is not supporting my
laptop very well (ACPI, soundcard, ...) - and that are the only reasons
why I mentioned the VPN software.

The UDP checksum for DNS requests was and is still, including kernel
2.6.8 incorrect for 8139too-driver with my Fujitsu Siemens Lifebook
E2010 and the

0000:00:11.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
        Subsystem: Fujitsu Limited.: Unknown device 11bd
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (8000ns min, 16000ns max)
        Interrupt: pin A routed to IRQ 11
        Region 0: I/O ports at 1800 [size=256]
        Region 1: Memory at dc003000 (32-bit, non-prefetchable)
[size=256]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

Network-Adapter  (lspci -vv Output) whether additional software is
installed or not.

And regarding:
> I've talked to Jeff Garzik (upstream 8139 and general network driver
> maintainer) about this.  He sais the UDP checksum code doesn't use
> crc32 so that cause can be ruled out and he's more suspicious that the
> cisco device is doing something funny.
>
> I'm not a networking expert but if you want someone to look at the
> ethereal traced you should probably ask at netdev@oss.sgi.com

There is a ISDN card(AVM FRITZ!Card PCMCIA 2.0), a modem card (3Com 56K
3CCM156B), I have a working (but old) laptop with an Intel Corp.
82557/8/9 [Ethernet Pro 100] network adapter. With all these network
devices the UDP checksums for DNS requests are ok. So for me it sounds
very very much for the 8139too-driver

If someone needs further information to solve the bug feel free to
contact me and understand on the other side that I don't want to give
network-traffic-traces to a great public for security reasons.

best regards
-kdm-

On Sat, 2004-08-28 at 18:22, Christoph Hellwig wrote:
> severity 254910 normal
> thanks
> 
> Any chance you could reproduce this without this cisco device (btw,
> a pointer to this devices' description would be nice, can't find it on
> their website)?  If not we'll probably close this.
> 
> 
> 

----- End forwarded message -----

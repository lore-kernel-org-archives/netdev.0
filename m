From: "Jaswinder Singh" <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #11271] BUG: fealnx in 2.6.27-rc1
Date: Sat, 13 Sep 2008 04:47:04 -0400
Message-ID: <3f9a31f40809130147w5b89cde0of87adbfc0193a441@mail.gmail.com>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	 <SpS7rta8n4.A.DCB.IfsyIB@albercik>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kernel Testers List" <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Francois Romieu" <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
	"Jeff Garzik" <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <SpS7rta8n4.A.DCB.IfsyIB@albercik>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello all,

On Fri, Sep 12, 2008 at 3:06 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:

> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=11271
> Subject         : BUG: fealnx in 2.6.27-rc1
> Submitter       : Jaswinder Singh <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date            : 2008-08-05 14:58 (39 days old)
> References      : http://marc.info/?l=linux-netdev&m=121794762016830&w=4
>                  http://lkml.org/lkml/2008/8/10/98

I am sorry for delay.

Now I am testing for same problem with  2.6.27-rc6.:
1. On different MYSON Technology Inc SURECOM EP-320X-S 100/10M
Ethernet PCI Adapters
2. On different Linux PCs
3. With different Ethernet switches which supports 100 Mb
4. With different CAT 5 ethernet cables which supports 100 Mb
5. Also checking old patches on fealnx as per Jeff.

And it seems, I am getting following error, with few ethernet switches
and cables and when I switch ethernet cables  :
"NETDEV WATCHDOG: eth0 (fealnx): transmit timed out
eth0: Transmit timed out, status 00000000, resetting..."

Now I am trying to confirm that problem is coming from ethernet
switches and cables.

I am also facing one more Issue :

With same 100 Mb ethernet switch and cable my another NIC run at 100
Mb/s and full duplex but MYSON Technology Inc SURECOM EP-320X-S
100/10M runs on 10 Mb/s and half duplex.

I debug fealnx it says : PHYType 1 duplex_mode : 2 line_speed : 2
crvalue : 0xe40e61 bcrvalue : 0x10 imrvalue : 0x46c flags : 0x1

So it is saying duplex_mode : 2 (full duplex) and line_speed = 2
(100M) then why I am getting 10MB half duplex ?

#lspci -vv
02:02.0 Ethernet controller: MYSON Technology Inc SURECOM EP-320X-S
100/10M Ethernet PCI Adapter
        Subsystem: MYSON Technology Inc SURECOM EP-320X-S 100/10M
Ethernet PCI Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 17
        Region 0: I/O ports at b800 [size=256]
        Region 1: Memory at ff9ffc00 (32-bit, non-prefetchable) [size=1K]
        Expansion ROM at 50000000 [disabled] [size=64K]
        Capabilities: [88] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA
PME(D0-,D1+,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: fealnx

#/sbin/ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  Not reported
        Advertised auto-negotiation: No
        Speed: 10Mb/s
        Duplex: Half
        Port: MII
        PHYAD: 32
        Transceiver: internal
        Auto-negotiation: off
        Current message level: 0x00000000 (0)
        Link detected: no

Thank you,

Jaswinder Singh.

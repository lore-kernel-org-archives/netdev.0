From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 19 Jun 2007 07:27:40 +0200
Message-ID: <20070619052740.GA1649@ff.dom.local>
References: <4bacf17f0706161435g1bb7c08bpd427901f64d57fa@mail.gmail.com> <20070618110849.GA2450@ff.dom.local> <20070618081000.14da5186@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070618081000.14da5186@localhost.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 18, 2007 at 08:10:00AM -0700, Stephen Hemminger wrote:
> On Mon, 18 Jun 2007 13:08:49 +0200
> Jarek Poplawski <jarkao2@o2.pl> wrote:
...
> > It looks like skge driver enables different device than probbed.
> > Maybe you've something old/wrong about eth0/eth1 in /etc configs?
> 
> More likely it is just user level device renaming. Most distro's
> rename devices (if needed) using udev.

I hope you're right, and the problem is resolved already, but for
historical reasons I'd notice the original message with quite a lot
of configs is available on linux-kernel.

Regards,
Jarek P.

> 
> > You can also try with netdev= or pci= kernel parameters.
> 
> Bad idea. 
> 
> > If no result - resend it, please - maybe with some debugging on
> > (modinfo skge). BTW - netdev seems to be preferred for this.
> 
> What is the contents of /proc/interrupts

--->

> On 16-06-2007 23:35, Marcin .lusarz wrote:
...
> joi ~ # cat /proc/interrupts ; sleep 5; cat /proc/interrupts
>           CPU0
>  0:     891160   IO-APIC-edge      timer
>  1:       2218   IO-APIC-edge      i8042
>  8:          2   IO-APIC-edge      rtc
>  9:          1   IO-APIC-fasteoi   acpi
> 12:       9110   IO-APIC-edge      i8042
> 14:          0   IO-APIC-edge      libata
> 15:        122   IO-APIC-edge      libata
> 17:         12   IO-APIC-fasteoi   eth1, eth0
> 18:      57275   IO-APIC-fasteoi   bttv0
> 20:      18810   IO-APIC-fasteoi   libata
> 21:          0   IO-APIC-fasteoi   ehci_hcd:usb1
> 22:      77945   IO-APIC-fasteoi   VIA8237
> NMI:          0
> LOC:     890924
> ERR:          0
>           CPU0
>  0:     896221   IO-APIC-edge      timer
>  1:       2219   IO-APIC-edge      i8042
>  8:          2   IO-APIC-edge      rtc
>  9:          1   IO-APIC-fasteoi   acpi
> 12:       9110   IO-APIC-edge      i8042
> 14:          0   IO-APIC-edge      libata
> 15:        122   IO-APIC-edge      libata
> 17:         12   IO-APIC-fasteoi   eth1, eth0
> 18:      57654   IO-APIC-fasteoi   bttv0
> 20:      18813   IO-APIC-fasteoi   libata
> 21:          0   IO-APIC-fasteoi   ehci_hcd:usb1
> 22:      78421   IO-APIC-fasteoi   VIA8237
> NMI:          0
> LOC:     895984
> ERR:          0
> 
> joi ~ # cat /proc/ioports
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 0050-0053 : timer1
> 0060-006f : keyboard
> 0070-0077 : rtc
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : 0000:00:0f.1
>  0170-0177 : libata
> 01f0-01f7 : 0000:00:0f.1
>  01f0-01f7 : libata
> 0290-0297 : pnp 00:09
> 02f8-02ff : serial
> 0376-0376 : 0000:00:0f.1
>  0376-0376 : libata
> 03c0-03df : vesafb
> 03f6-03f6 : 0000:00:0f.1
>  03f6-03f6 : libata
> 03f8-03ff : serial
> 0400-0407 : vt596_smbus
> 0680-06ff : pnp 00:09
> 0800-0803 : ACPI PM1a_EVT_BLK
> 0804-0805 : ACPI PM1a_CNT_BLK
> 0808-080b : ACPI PM_TMR
> 0810-0815 : ACPI CPU throttle
> 0820-0823 : ACPI GPE0_BLK
> 0cf8-0cff : PCI conf1
> 1000-10ff : 0000:00:11.6
> a800-a8ff : 0000:00:0a.0
>  a800-a8ff : skge
> b000-b01f : 0000:00:0c.0
>  b000-b01f : ne2k-pci
> b400-b4ff : 0000:00:0f.0
>  b400-b4ff : sata_via
> b800-b80f : 0000:00:0f.0
>  b800-b80f : sata_via
> c000-c003 : 0000:00:0f.0
>  c000-c003 : sata_via
> c400-c407 : 0000:00:0f.0
>  c400-c407 : sata_via
> c800-c803 : 0000:00:0f.0
>  c800-c803 : sata_via
> d000-d007 : 0000:00:0f.0
>  d000-d007 : sata_via
> d400-d41f : 0000:00:10.0
> d800-d81f : 0000:00:10.1
> e000-e01f : 0000:00:10.2
> e400-e41f : 0000:00:10.3
> e800-e8ff : 0000:00:11.5
>  e800-e8ff : VIA8237
> fc00-fc0f : 0000:00:0f.1
>  fc00-fc0f : libata
> 
> joi ~ # cat /proc/iomem
> 00000000-0009fbff : System RAM
> 0009fc00-0009ffff : reserved
> 000c0000-000dffff : pnp 00:0e
> 000e4000-000fffff : reserved
> 00100000-3ffaffff : System RAM
>  00200000-0059ebc7 : Kernel code
>  0059ebc8-0077248f : Kernel data
> 3ffb0000-3ffbffff : ACPI Tables
> 3ffc0000-3ffeffff : ACPI Non-volatile Storage
> 3fff0000-3fffffff : reserved
> e8000000-ebffffff : 0000:00:00.0
>  e8000000-ebffffff : aperture
> efe00000-efe00fff : 0000:00:0d.0
>  efe00000-efe00fff : bttv0
> eff00000-eff00fff : 0000:00:0d.1
> f0000000-f9ffffff : PCI Bus #01
>  f0000000-f7ffffff : 0000:01:00.0
>    f0000000-f7ffffff : vesafb
> faa00000-faa1ffff : 0000:00:0a.0
> fab00000-fab03fff : 0000:00:0a.0
>  fab00000-fab03fff : skge
> fac00000-fac07fff : 0000:00:0c.0
> fae00000-fae000ff : 0000:00:10.4
>  fae00000-fae000ff : ehci_hcd
> faf00000-fbffffff : PCI Bus #01
>  faf00000-faf1ffff : 0000:01:00.0
>  fb000000-fbffffff : 0000:01:00.0
> fec00000-fec00fff : IOAPIC 0
>  fec00000-fec00fff : pnp 00:0b
> fee00000-fee00fff : Local APIC
> ff780000-ffffffff : reserved
> 
> joi ~ # cat /proc/sys/kernel/tainted
> 0
...

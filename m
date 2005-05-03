From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Mystery packet killing tg3
Date: Tue, 3 May 2005 14:29:52 -0700
Message-ID: <20050503142952.527c33c5@dxpl.pdx.osdl.net>
References: <20050502162405.65dfb4a9@localhost.localdomain>
	<20050502200251.38271b61.davem@davemloft.net>
	<20050503140528.1bd2ac74@dxpl.pdx.osdl.net>
	<20050503141314.441c9d75.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503141314.441c9d75.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005 14:13:14 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Tue, 3 May 2005 14:05:28 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > 00:0b.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X APIC (rev 01) (prog-if 10 [IO-APIC])
> 
> Buggy 8131 APIC, does the drivers/pci/quirks.c:quirk_amd_8131_ioapic()
> message:
> 
> PCI: MSI quirk detected. pci_msi_quirk set.

yes. that is there.

> trigger?  MSI support recently got added to the tg3.c driver, but it should
> only register MSI interrupt handling if pci_enable_msi() returns zero.

There is no call to pci_enable_msi in the 2.6.12-rc3 source

> See what it ends up doing, or if you even have a MSI capable tg3.c in
> your kernel.

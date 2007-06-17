From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: high ping times with wireless-dev
Date: Sun, 17 Jun 2007 14:12:44 +0200
Message-ID: <200706171412.45074.mb@bu3sch.de>
References: <200706162327.47413.maxi@daemonizer.de> <200706171255.40155.mb@bu3sch.de> <200706171403.34299.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200706171403.34299.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 17 June 2007 14:03:30 Maximilian Engelhardt wrote:
> On Sunday 17 June 2007, Michael Buesch wrote:
> > On Saturday 16 June 2007 23:27:43 Maximilian Engelhardt wrote:
> > > [...]
> > > ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
> > > ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, low)
> > > -> IRQ 10
> > > ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
> > > b44.c:v2.0
> > > eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
> > > [...]
> >
> > Ok, I prepared two debugging patches.
> >
> > Please enable SonicsSiliconBackplane Debugging in the kernel kconfig,
> > so I can get more detail information about your card.
> > Device Drivers/Sonics Silicon Backplane/SSB debugging
> > (Must disable "No SSB kernel messages")
> >
> > Please apply and test the attached debugging patches in a row.
> > So apply patch 1 and test if it works again. If not, apply
> > patch 2 and test if it works.
> > Always save complete dmesg log on each test run and send it to me.
> >
> > Thanks for testing.
> > (This time it seems we are actually getting somewhere, when
> > dealing with sane people. :D )
> 
> I did the tests with my kernel where only the card is on interrupt 10. dmesg 
> is attached.
> With the first patch applied networking does work again. I also additionally 
> tried patch2 and it also does work.

Great!
To me this seems to be a silicon bug. The IRQ routing value, which is read
from the chip here, is hardcoded in the old b44 driver.
I'll implement a workaround for this and submit a patch.

-- 
Greetings Michael.

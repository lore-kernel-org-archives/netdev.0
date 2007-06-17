From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: high ping times with wireless-dev
Date: Sun, 17 Jun 2007 13:08:38 +0200
Message-ID: <200706171308.39169.mb@bu3sch.de>
References: <200706162327.47413.maxi@daemonizer.de> <200706171255.40155.mb@bu3sch.de>
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
In-Reply-To: <200706171255.40155.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 17 June 2007 12:55:39 Michael Buesch wrote:
> On Saturday 16 June 2007 23:27:43 Maximilian Engelhardt wrote:
> > [...]
> > ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
> > ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, low) -> 
> > IRQ 10
> > ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
> > b44.c:v2.0
> > eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
> > [...]
> 
> Ok, I prepared two debugging patches.
> 
> Please enable SonicsSiliconBackplane Debugging in the kernel kconfig,
> so I can get more detail information about your card.
> Device Drivers/Sonics Silicon Backplane/SSB debugging
> (Must disable "No SSB kernel messages")
> 
> Please apply and test the attached debugging patches in a row.
> So apply patch 1 and test if it works again. If not, apply
> patch 2 and test if it works.
> Always save complete dmesg log on each test run and send it to me.
> 
> Thanks for testing.
> (This time it seems we are actually getting somewhere, when
> dealing with sane people. :D )
> 

Ah, forgot to say. Apply patch 2 on top of patch 1.

-- 
Greetings Michael.

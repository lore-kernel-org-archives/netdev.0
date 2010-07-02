From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iwl3945: HARDWARE GONE??
Date: Fri, 2 Jul 2010 09:48:59 -0700
Message-ID: <20100702094859.07190a0a@nehalam>
References: <1278086575.2889.8.camel@chi>
	<20100702162650.GC2381@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Priit Laes <plaes@plaes.org>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100702162650.GC2381@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Jul 2010 12:26:50 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> On Fri, Jul 02, 2010 at 07:02:55PM +0300, Priit Laes wrote:
> > Heya!
> > 
> > Bumped my kernel to version 2.6.35-rc3-00391-g97e0214 and ran into
> > HARDWARE GONE error message..
> > 
> > Hardware is Lenovo x60s and wireless card is intel 3945:
> > 
> > 03:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG [Golan] Network Connection (rev 02)
> > 	Subsystem: Intel Corporation ThinkPad R60e/X60s
> > 	Flags: bus master, fast devsel, latency 0, IRQ 47
> > 	Memory at edf00000 (32-bit, non-prefetchable) [size=4K]
> > 	Capabilities: [c8] Power Management version 2
> > 	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> > 	Capabilities: [e0] Express Legacy Endpoint, MSI 00
> > 	Capabilities: [100] Advanced Error Reporting
> > 	Capabilities: [140] Device Serial Number 00-xx-xx-xx-xx-xx-xx-xx
> > 	Kernel driver in use: iwl3945
> > 	Kernel modules: iwl3945
> > 
> > I have attached dmesg error message...
> > 
> > Cheers,
> > Priit :)
> 
> > [13813.347617] Uhhuh. NMI received for unknown reason a1 on CPU 0.
> > [13813.347617] You have some hardware problem, likely on the PCI bus.
> > [13813.347617] Dazed and confused, but trying to continue
> > [13813.347617] iwl3945 0000:03:00.0: HARDWARE GONE?? INTA == 0xffffffff
> 
> We've been seeing this sort of thing a lot -- somehow the iwl3945 gets
> disconnected from the PCI bus.  Anyone have any clue how that happens?

Usually this kind of problem is a power management issue.

From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Thu, 2 Aug 2007 18:18:57 +0200
Message-ID: <200708021818.58319.mb@bu3sch.de>
References: <200707271857.24162.mb@bu3sch.de> <200708021624.59701.mb@bu3sch.de>
	<Pine.LNX.4.64.0708021812260.5150@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0708021812260.5150@anakin>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 02 August 2007, Geert Uytterhoeven wrote:
> On Thu, 2 Aug 2007, Michael Buesch wrote:
> > On Thursday 02 August 2007, Geert Uytterhoeven wrote:
> > > On Fri, 27 Jul 2007, Michael Buesch wrote:
> > > > The Sonics Silicon Backplane is a mini-bus used on
> > > > various Broadcom chips and embedded devices.
> > > > Devices using the SSB include b44, bcm43xx and various
> > > > Broadcom based wireless routers.
> > > > A b44 and bcm43xx port and a SSB based OHCI driver is available.
> > > 
> > > > --- a/drivers/Kconfig
> > > > +++ b/drivers/Kconfig
> > > > @@ -58,6 +58,8 @@ source "drivers/power/Kconfig"
> > > >  
> > > >  source "drivers/hwmon/Kconfig"
> > > >  
> > > > +source "drivers/ssb/Kconfig"
> > > > +
> > > >  source "drivers/mfd/Kconfig"
> > > >  
> > > >  source "drivers/media/Kconfig"
> > > 
> > > > --- /dev/null
> > > > +++ b/drivers/ssb/Kconfig
> > > > @@ -0,0 +1,92 @@
> > > > +menu "Sonics Silicon Backplane"
> > > > +
> > > > +config SSB
> > > > +	tristate "Sonics Silicon Backplane support"
> > > > +	depends on EXPERIMENTAL
> > > 
> > > Hence this will show up on all platforms?
> > 
> > So?
> 
> Shouldn't you add a dependency for platforms where it make sense to have SSB?

Well, that's everything where you can stick a PCI, PCMCIA, PC-Card or CF-Card
into, plus the MIPS platform, where we have the embedded SSB.
That's basically everything, no? Except these strange !HAS_IOMEM platforms,
which we already take care of in a followup patch.

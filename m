From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH] enc28j60: Fix sporadic packet loss
	(correction)
Date: Tue, 2 Dec 2008 23:04:20 -0800
Message-ID: <200812022304.20661.david-b@pacbell.net>
References: <20081202085947.GB24490@diamond.tkos.co.il>
	<200812021444.03225.david-b@pacbell.net>
	<20081203062213.GB3361@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Claudio Lanconelli <lanconelli.claudio-DtroZxfa9uMAvxtiuMwx3w@public.gmane.org>,
	Shachar Shemesh <shachar-bEkjeIDUMOLQT0dZR+AlfA@public.gmane.org>,
	Network development list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Return-path: <spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20081203062213.GB3361@tarshish>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=spi-devel-general>
List-Post: <mailto:spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 02 December 2008, Baruch Siach wrote:

> Apparently I haven't explained myself clear enough. The (partial) driver that 
> Peter Pearse has posted[1] to LAKL is for the PL080 DMA controller. This 
> driver is ARM specific, so LAKL seems to be reasonable place even though the 
> driver itself is under drivers/amba (which is ARM specific as well).

Actually AMBA has generalized past being ARM-specific.
It's just a chip-internal bus, and the silicon-IP
end of ARM Ltd has been successful enough that vendors
use it with non-ARM CPUs too.

Example:  you'll notice that drivers/dma/dw_dmac.c was
first used on a non-ARM system; it's a Synopsys DesignWare
(dw) DMA controller (dmac) for AMBA2, with AHB and APB.

So let me suggest LKML, with an FYI to the ARM list,
and putting that driver in drivers/dma instead. :)


But yes, now I see what you mean:  discrete DMA and SPI
drivers.

- Dave


> My Synopsys DesignWare SPI master driver will, when complete, depend on this 
> DMA controller driver, that's not in the mainline (yet).
> 
> > Post it to the SPI list instead.  ...

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/

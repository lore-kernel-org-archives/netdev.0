From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH] enc28j60: Fix sporadic packet loss
	(correction)
Date: Tue, 2 Dec 2008 14:44:02 -0800
Message-ID: <200812021444.03225.david-b@pacbell.net>
References: <20081202085947.GB24490@diamond.tkos.co.il>
	<200812021305.06083.david-b@pacbell.net>
	<20081202213459.GA3361@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Claudio Lanconelli <lanconelli.claudio-DtroZxfa9uMAvxtiuMwx3w@public.gmane.org>,
	Shachar Shemesh <shachar-bEkjeIDUMOLQT0dZR+AlfA@public.gmane.org>,
	Network development list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Return-path: <spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20081202213459.GA3361@tarshish>
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
> Hi David,
> 
> On Tue, Dec 02, 2008 at 01:05:05PM -0800, David Brownell wrote:
> > Seems plausible to me, but network patches should be submitted
> > to the netdev list.  :)
> 
> So I did after Claudio suggested the same (and acked the patch).

Good, thanks.


> > p.s. Just for info ... what kind of Linux system are you using
> >    this driver on?
> 
> I'm using this driver on a custom chip that includes ARM926 core. The kernel 
> version is (currently) 2.6.26. The SPI bus on this chip is the only way to 
> connect peripherals.  That's way we're stuck with this Ethernet interface.

It's a bit sub-optimal ... but I'm glad you've got that option!  :)

 
> Our on-chip SPI master is the Synopsys DesignWare one. I wrote a driver for 
> this SPI master. This driver is somewhat usable, but not complete yet. I'm now 
> in the process of adding DMA support to the driver (PL080) to overcome some 
> nasty  design peculiarities of this SPI master.
> 
> Peter Pearse has poster a (incomplete) patch set with a driver for the PL080 
> DMA controller to the LAKL last week, but I see no push for integrating it 
> into the mainline. So I doubt there's any great value in this SPI master 
> driver as of now.

I certainly wouldn't expect that on the ARM list.  It's
not exactly the responsibility of that list to address
anything other than arch/arm/* goodies.

Post it to the SPI list instead.  If it's useful to you,
it could well be useful to others... I'd have no problems
merging such a driver, if it's reasonably clean/correct
and is known to work well enough to support enc28j60.

- Dave

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/

From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI
	Express devices
Date: Wed, 9 Apr 2008 21:08:36 +0200
Message-ID: <20080409190836.GA9276@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080408083606.GA20863@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> * Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> 
> > From kernel 2.6.26 onward all *PCI Express* device IDs previously 
> > supported by e1000 will be moving to the e1000e driver.  This 
> > includes ich8 and ich9 onboard LAN, server 5000 platform onboard LAN 
> > (es2) and 82571/2/3 chipset based adapters and variants.
> > 
> > If you have not already enabled CONFIG_E1000E make sure that you do 
> > so. You can already do this with 2.6.25.  From 2.6.26 on this change 
> > will be required if you have such a device.
> 
> i'm not sure it's a good idea to unsupport hardware in a driver. It's 
> OK to phase out a driver and restrict it to legacy hardware, it's OK 
> to have an opt-in .config option for distros to select (or maybe even 
> opt-out) to narrow down the number of PCI IDs that a driver 
> recognizes, but lets not artificially break setups that worked before.

perhaps all the opposition with regard to the regression roots back to 
this section i said, so i take this objection back - it looks quite 
acceptable to do the migration the way you implemented it, considering 
the choices.

except for the E1000=y && E1000E=m regression that bit me - that should 
be solved and everyone will be happy.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

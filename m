From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI
	Express devices
Date: Tue, 8 Apr 2008 20:15:10 +0200
Message-ID: <20080408181510.GA16593@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com>
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
In-Reply-To: <47FB9ABB.9080403@intel.com>
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


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> > The following .config results in a non-working e1000 driver in a 
> > bzImage:
> > 
> >  CONFIG_E1000=y
> >  CONFIG_E1000_NAPI=y
> >  CONFIG_E1000_DISABLE_PACKET_SPLIT=y
> >  CONFIG_E1000E=m
> >  CONFIG_E1000E_ENABLED=y
> > 
> > the interface just doesnt come up.
> > 
> > This makes it work:
> > 
> >  CONFIG_E1000=y
> >  CONFIG_E1000_NAPI=y
> >  CONFIG_E1000_DISABLE_PACKET_SPLIT=y
> >  # CONFIG_E1000E is not set
> >  # CONFIG_E1000E_ENABLED is not set
> > 
> > please fix such interactions and make the transition as smooth and as 
> > compatible as possible.
> 
> This is really a vague report. Maybe you need to adjust your network 
> setup to explicitly load the correct driver at boot? The adapter works 
> correct here and I have a stock T60 here as well, just as you.

try the config combination i gave you [that's all that is needed - plug 
the above lines into your .config of choice] - does that work fine for 
you?

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

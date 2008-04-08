From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI
	Express devices
Date: Tue, 08 Apr 2008 16:56:52 +0200
Message-ID: <87iqyspf7v.fsf@basil.nowhere.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Ronciak,  John" <john.ronciak@intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080408083606.GA20863@elte.hu> (Ingo Molnar's message of "Tue,
	8 Apr 2008 10:36:06 +0200")
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

Ingo Molnar <mingo@elte.hu> writes:
>
> ( sidenote: isnt there some facility that selects the "better" driver in 
>   case there is an overlap between PCI IDs - with the ability for users 
>   to override that selection? )

The default action for driver auto loaders in this case is usually to load
all of them unless specially overriden. That is because there are several
cases where one PCI-ID implements multiple functions served by different
drivers. So far there is no really clean solution to this problem and for
e1000 with PCI-E IDs it would do the wrong thing.

-Andi

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

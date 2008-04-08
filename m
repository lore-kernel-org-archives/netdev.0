From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 8 Apr 2008 22:06:52 +0200
Message-ID: <20080408200652.GC28148@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Matthew Wilcox <matthew@wil.cx>,
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
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <47FBCE00.2020309@garzik.org>
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


* Jeff Garzik <jeff@garzik.org> wrote:

> Then disable E1000E in your kernel config, and the PCIE() macro will 
> do the right thing...

it is an obvious regression that could and should be solved in the 
Kconfig space: do not allow E1000=y && E1000E=m.

i repeat, it took me more than an hour to figure out why there's no 
networking on my laptop. Guess how much it takes for a plain user to 
figure out the same problem.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

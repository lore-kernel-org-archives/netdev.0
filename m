From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 8 Apr 2008 22:33:14 +0200
Message-ID: <20080408203314.GA28952@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
	<20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org>
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
In-Reply-To: <47FBD34A.6080508@garzik.org>
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

> Ingo Molnar wrote:
>> i repeat, it took me more than an hour to figure out why there's no 
>> networking on my laptop. Guess how much it takes for a plain user to 
>> figure out the same problem.
>
> A plain user would have obtained a working distro kernel, putting this 
> rare problem purely in the laps of people with highly unusual kernel 
> configs...
>
> But as noted in the announcement, the fix is for this is to continue 
> in the next step in the transition, then you only have one driver 
> claiming those IDs, for any given config.  No need for further Kconfig 
> tweakage.

i find it mindboggling and rather sad that you are still in denial :-(

this is an obvious regression to me, with a very simple fix. No other 
PCI driver breaks like this. We've got three thousand Kconfig options - 
it is clearly not realistic for users to keep such details in mind to 
avoid pitfalls. E1000=y && E1000E=m is uncommon but can easily happen. 
E1000=y && E1000E=m simply makes no sense in light of the PCI ID 
stealing that occurs if E1000E is enabled.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

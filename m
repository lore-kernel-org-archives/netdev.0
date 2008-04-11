From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 13:26:53 +0200
Message-ID: <20080411112653.GC9205@elte.hu>
References: <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu>
	<47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu>
	<47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com>
	<20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
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
In-Reply-To: <47FE8566.5040809@intel.com>
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

> Again - this has happened before, I remember many of my boxes not 
> booting because SATA Kconfig options changed and all my boxes failed 
> to move the proper Kconfig symbols over when I ran `make oldconfig` 
> myself. Somewhere around 2.6.20 or so.

that's an insane argument ... because we messed up in the past and have 
hurt users (and probably lost users) you feel like it gives you a free 
card to mess up again???

The IDE -> SATA migration, while i like the new SATA code and find it 
excellent and well-maintained (many kudos for that to Tejun, Jeff, Alan 
& co), caused a lot of trouble for users in one specific area, for no 
good reasons other than stupid personality conflicts: /dev/hda worked 
just as well as /dev/sda, the _name_ of the device should never have 
been changed.

So if you use _that_ aspect of the (otherwise cool) SATA/PATA code as a 
blueprint for the e1000 -> e1000e migration then you are on the worst 
possible track in terms of picking a role model ;-) It's as if you 
adored Sylvester Stallone for his vivid mimics, Jean-Claude Van Damne 
for his excellent acting skills and Paris Hilton for her brillant brain.

really, just because you do exceedingly good things to Linux does not 
give you a free card to do something bad to Linux in exchange. The two 
do not cancel out each other - because the bad things _add up_ and drive 
away users, irreversibly. To you e1000 is the center of the universe so 
you feel the price is worth paying. For others it is not. We want the 
good things from you and we'll say no thanks to the bad ideas. Kernel 
developers, especially old-timers, regularly forget about that.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

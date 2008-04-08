From: Dan Noe <dpn@isomerica.net>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 08 Apr 2008 16:12:29 -0400
Message-ID: <47FBD1AD.1080700@isomerica.net>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com>
	<20080408195949.GB28148@elte.hu>
	<20080408200417.GI11962@parisc-linux.org>
Reply-To: dpn@isomerica.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080408200417.GI11962@parisc-linux.org>
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

Matthew Wilcox wrote:
> It's almost trivial to add new string attributes to sysfs.  We could
> have a file, say, /sys/bus/pci/devices/0000:07:03.0/broken which
> lspci could read to see if anything's left a message for us.
> 
> Is that the kind of thing you had in mind?

I would consider this a worthwhile addition to the kernel (and lspci). 
It would be nice if lspci could display what driver had claimed a 
particular device, and which devices were unclaimed by any driver or 
otherwise had an error that prevented initialization.

I don't have enough experience to gauge how invasive this would be, but 
I'd be happy to contribute towards it if practical.

Cheers,
Dan

-- 
                     /--------------- - -  -  -   -   -
                     |  Daniel Noe
                     |  http://isomerica.net/~dpn/

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

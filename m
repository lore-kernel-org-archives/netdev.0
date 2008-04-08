From: Dan Noe <dpn@isomerica.net>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 08 Apr 2008 16:39:26 -0400
Message-ID: <47FBD7FE.1060507@isomerica.net>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com>
	<20080408195949.GB28148@elte.hu>
	<20080408200417.GI11962@parisc-linux.org>
	<47FBD1AD.1080700@isomerica.net>
	<20080408202003.GJ11962@parisc-linux.org>
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
In-Reply-To: <20080408202003.GJ11962@parisc-linux.org>
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
> On Tue, Apr 08, 2008 at 04:12:29PM -0400, Dan Noe wrote:
>> It would be nice if lspci could display what driver had claimed a 
>> particular device
> 
> You need to upgrade to a more recent version of lspci -- it already does
> this ;-)

Hah, thanks.  That is useful and very new :)  I built a newer lspci and 
I see it is now displayed with the -k option.

> Maybe 'status' would be a better name than 'broken'.  We could even
> default it to 'unclaimed' then.  Or 'driver_status' to avoid conflicting
> with some bus that might have a 'status' bit we try to report through
> sysfs.

I agree however that the opportunity for more status would be good.  And 
status is a better name than "broken".  This way it is easy to scan all 
devices on the system via sysfs and easily visualize via lspci or some 
other tool:

1) Unclaimed devices

2) Devices that aren't working properly - and why (please something more 
than "This device is not working properly" :)

3) Devices that are claimed and working properly

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

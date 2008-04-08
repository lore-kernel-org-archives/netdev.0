From: Martin Mares <mj@ucw.cz>
Subject: Re: showing which hardware is unclaimed
Date: Tue, 8 Apr 2008 22:35:55 +0200
Message-ID: <mj+md-20080408.203457.10351.albireo@ucw.cz>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com>
	<20080408195949.GB28148@elte.hu>
	<20080408200417.GI11962@parisc-linux.org> <47FBD1CD.6090009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <47FBD1CD.6090009@hp.com>
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

Hi!

> FWIW, this is what a command on "another OS" does with an unclaimed card:
> 
> # ioscan -fk -C lan
> Class     I  H/W Path  Driver  S/W State   H/W Type     Description
> ====================================================================
> lan       0  0/0/3/0   intl100   CLAIMED     INTERFACE    Intel PCI Pro 
> 10/100Tx Server Adapter
> lan       1  0/1/2/0   igelan    CLAIMED     INTERFACE    HP PCI 
> 1000Base-T Core
> lan       2  0/2/1/0   iether    CLAIMED     INTERFACE    HP A7012-60001 
> PCI/PCI-X 1000Base-T Dual-port Adapter
> lan       3  0/2/1/1   iether    CLAIMED     INTERFACE    HP A7012-60001 
> PCI/PCI-X 1000Base-T Dual-port Adapter
> lan       4  0/3/1/0   ixgbe     UNCLAIMED   UNKNOWN      PCI-X Ethernet 
> (17d55831)
> 
> I'd probably call that "unclaimed" rather than "broken" but that may 
> just be a preference thing.

`lspci -k' already reports which devices are claimed by which driver.

				Have a nice fortnight
-- 
Martin `MJ' Mares                          <mj@ucw.cz>   http://mj.ucw.cz/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
MS has designed a perfect copy protection scheme: There is no reason to pirate Vista.

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

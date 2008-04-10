From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix (was:
 Re: [regression] e1000e broke e1000)
Date: Wed, 9 Apr 2008 18:40:24 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0804091838330.3143@woody.linux-foundation.org>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com>
	<20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
	<20080408200652.GC28148@elte.hu>
	<47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu>
	<47FBDBE9.9040700@garzik.org> <47FBDBE9.9040700@garzik.org>
	<20080409193850.GA11763@elte.hu>
	<200804092249.23111.elendil@planet.nl>
	<m363uqwpds.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, akpm@linux-foundation.org,
	jeff@garzik.org, matthew@wil.cx, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Frans Pop <elendil@planet.nl>,
	bruce.w.allan@intel.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, rjw@sisk.pl, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, greg@kroah.com, Ingo Molnar <mingo@elte.hu>,
	arjan@linux.intel.com, linux-pci@atrey.karlin.mff.cuni.cz
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <m363uqwpds.fsf@maximus.localdomain>
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



On Thu, 10 Apr 2008, Krzysztof Halasa wrote:
> 
> Nope, udev with normal distro config will load e1000e just fine.

Not for us that don't compile modules at all, or only modules for the 
devices we actually have.

Which should be about 99% of all kernel developers, because otherwise 
you're just wasting your time.

I certainly want the configurations to be sane by default, because I'm not 
in the insane camp that has every single module and depend on udev picking 
the right one out.

			Linus

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

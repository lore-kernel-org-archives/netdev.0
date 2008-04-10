From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [patch] e1000=y && e1000e=m regression fix (was:
	Re: [regression] e1000e broke e1000)
Date: Thu, 10 Apr 2008 23:35:37 +0200
Message-ID: <m3prsxpf4m.fsf@maximus.localdomain>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com>
	<20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
	<20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org>
	<20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org>
	<47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<200804092249.23111.elendil@planet.nl>
	<m363uqwpds.fsf@maximus.localdomain>
	<alpine.LFD.1.00.0804091838330.3143@woody.linux-foundation.org>
	<m34paaav7o.fsf@maximus.localdomain>
	<alpine.LFD.1.00.0804100724220.3143@woody.linux-foundation.org>
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LFD.1.00.0804100724220.3143@woody.linux-foundation.org>
	(Linus Torvalds's message of "Thu\,
	10 Apr 2008 07\:30\:34 -0700 \(PDT\)")
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

Linus Torvalds <torvalds@linux-foundation.org> writes:

> No it wouldn't, not when the driver we used forever suddenly stopped 
> supporting them.

In this case e1000 stops supporting them only if you enable e1000e
too. No e1000e, e1000 still does those IDs. For now, if I understand
it correctly. And it seems to print a warning.

So it doesn't work if you make e1000e a module and don't load it.

> And no, I'm not talking about some theoretical "this could happen" thing. 
> I hit exactly that with commit
> 040babf9d84e7010c457e9ce69e9eb1c27927c9e 

Right. Now it's a different situation, though.
-- 
Krzysztof Halasa

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

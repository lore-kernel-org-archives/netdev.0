From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Wed, 9 Apr 2008 22:04:33 +0200
Message-ID: <20080409200433.GA18968@elte.hu>
References: <20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
	<20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org>
	<20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org>
	<20080409193850.GA11763@elte.hu> <47FD1DF6.2000007@garzik.org>
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
In-Reply-To: <47FD1DF6.2000007@garzik.org>
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
>> * Jeff Garzik <jeff@garzik.org> wrote:
>>
>>>> We've got three thousand Kconfig options - it is clearly not realistic 
>>>> for users to keep such details in mind to avoid pitfalls.
>>> Agreed -- hence the multiple announcements, including in this thread, to 
>>> put said details into mind.
>>
>> which part of "it took a kernel developer more than an hour to figure 
>> out why his laptop had a dead network interface" did you not 
>> understand? Whatever you did, it was not apparent to me. I dont 
>> follow every tiny detail of the e1000 driver family, nor do 99%+ [*] 
>> of our users.
>
> You do follow LKML, where multiple announcements have and are being 
> posted.

... what you say is contrary to the well-known regression rules of the 
upstream kernel. You cannot seriously expect users to follow mailings 
related to the 8+ million lines of code kernel they are utilizing, just 
to not end up with a dead networking interface ....

so please comment on the fix i sent. The patch solves the problem i had 
and it's end of this story as far as i'm concerned. Do you have any 
strong technical argument why it should not be applied?

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

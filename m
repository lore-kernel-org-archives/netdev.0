From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 14:16:07 +0200
Message-ID: <20080411121606.GA25661@elte.hu>
References: <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu>
	<47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com>
	<20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
	<20080411112653.GC9205@elte.hu>
	<20080411113644.GA7767@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
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
To: Christoph Hellwig <hch@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080411113644.GA7767@infradead.org>
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


* Christoph Hellwig <hch@infradead.org> wrote:

> And this is not really comparable to the libata transition at all, 
> there's no user-visible changed. [...]

well it was Auke who compared it to the libata transition not me ...

> [...] For every distro kernel that just builds both driver it's a 
> completely seamless transition, and for people who build their own 
> kernel we should find some Kconfig trickery to make the transition 
> easier.  For example we could just built e1000e when CONFIG_E1000 is 
> set and spill a warning that starting from 1.1.2009 you will have to 
> have CONFIG_E1000E set aswell.

firstly, a good deal of our alpha testers use =y drivers. Secondly, your 
kind of constructive email is exactly what i wanted to see in the first 
place...

i dont really care _how_ this gets solved - i'm not maintaining this 
code. What forced me to deal with it was this outright denial of my 
problem, the ridiculing and NACK-ing of it and general stonewalling.

I'd have preferred to have sent only my first report. The networking 
driver guys on the other hand:

 1) forced me to send a full bugreport about something that i described
    adequately in my very first mail already, and which they should have
    immediately recognized, based on the trouble they had with Linus. (i
    wasnt aware of that back when i made my report)

 2) repeatedly denied that there is any problem. Claimed that "this is a 
    careful migration balance we decided" and other babbling.

 3) forced me to write a patch for code they are supposed to be 
    maintaining to actually get things moving.

 4) moved the regression bugzilla entry to REJECTED+INVALID without 
    actually resolving the bug and forced me to write several comments 
    there too. (See http://bugzilla.kernel.org/show_bug.cgi?id=10427)

 5) forced me to write 20 mails with still no clear resolution yet at
    this point.

it's insane and i'm really curious what kind of language you'd use in 
your replies if i ever forced you through such an excercise in arch/x86 
or the scheduler ;-)

and no, it wasnt a case of miscommunication. My bug was i think 
well-understood in the very first mailings already, but it was 
discounted as unimportant and resolution was delayed all the way up 
until this point. That shows fundamental insensitivity to bug reporters 
which is more worrisome than the bug itself (the bug is fairly minor and 
i never claimed otherwise).

Hours of my time wasted on something that should have been a 2 minutes 
matter - and yes, as i go through these chores i do get increasingly 
annoyed about it, and rightfully so. I cannot just let this happen 
silently, way too much crap like this gets pulled off. If the networking 
driver guys are pulling off a show like that with a fellow kernel 
developer how do they manage to deal with plain users (who, in 
comparison, are in essence defense-less against rejections from 
maintainers)?

and yes, moving those IDs over into e1000e in v2.6.26 might work out 
fine in the end, if the migration is all totally problem free up to that 
point. We simply cannot make that determination right now. What exactly 
is so hard to understand about the concept of not degrading the quality 
of an existing, rather well-working driver?

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 13:29:22 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0804111327200.3143@woody.linux-foundation.org>
References: <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com>
	<20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
	<20080411112653.GC9205@elte.hu>
	<20080411113644.GA7767@infradead.org>
	<20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
	<20080411164542.GA4066@infradead.org>
	<alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
	<20080411175304.GF11962@parisc-linux.org>
	<alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org>
	<m3fxtsp2eq.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <m3fxtsp2eq.fsf@maximus.localdomain>
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



On Fri, 11 Apr 2008, Krzysztof Halasa wrote:

> Linus Torvalds <torvalds@linux-foundation.org> writes:
> 
> > Nobody wants to care deeply whether it's a PCI-E or PCI chip. In fact, 
> > it's almost impossible to tell. Here, quickly, tell me which one mine is 
> > (this is from /sbin/lspci):
> >
> > 	00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)
> >
> > and tell me how you knew..
> 
> I guess PCIE. You already came across a similar problem.
> 
> Have I won something? :-)

Nope. You apparently guessed just because I had told earlier about how the 
E1000 changes screwed over my setup.

The fact is, people don't know. And they shouldn't care. If the E1000 
driver worked before, we simply shouldn't break that from a configuration 
standpoint.

			Linus

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

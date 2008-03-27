From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 16:06:33 -0700 (PDT)
Message-ID: <20080327.160633.241066028.davem@davemloft.net>
References: <47EBF8EE.1000102@garzik.org>
	<20080327.150555.113590579.davem@davemloft.net>
	<36D9DB17C6DE9E40B059440DB8D95F5204C27573@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, jeff@garzik.org
To: jesse.brandeburg@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204C27573@orsmsx418.amr.corp.intel.com>
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

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 27 Mar 2008 15:55:34 -0700

> David Miller wrote:
> > From: Jeff Garzik <jeff@garzik.org>
> > Date: Thu, 27 Mar 2008 15:43:42 -0400
> > 
> >> But that seems like a quick id test, with no need for all that
> >> generic MSI test code.
> > 
> > Yes, that is the way to do it.
> 
> I get your point, but this seems a maintainance problem due to not being
> able to "future proof" the solution.  I know what is (IDs) available
> now, but I don't know how many systems in the future IBM will release
> with a similar bridge but a different device ID that causes the same
> issue.  Should we take on the maintenance of continually having to add
> every new bridge device that has this issue to our driver?  Users just
> want this stuff to work when they plug it in.

This is exactly what the PCI quirks list is and it works just fine.

I know the truth is that Intel as a vendor frowns upon putting into
it's driver a list of another vendor's PCI IDs as errata items because
it looks bad.

So just be honest about that.

It is, however, the correct way to address this problem.

> tg3.c has exactly this kind of test and workaround (in fact its where I
> got the code) to work around the same kind of issues.

That is from an era when the situation was much different.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace

From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: 2.6.29 e100.c non-MII support status? (Re: [GIT]:
	Networking)
Date: Sat, 28 Feb 2009 21:37:57 +0100
Message-ID: <20090228203757.GA18850@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net>
	<20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<20081229091728.d869f1c1.akpm@linux-foundation.org>
	<9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com>
	<20081230120756.GA5393@rhlx01.hs-esslingen.de>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bunk@kernel.org, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: andi@lisas.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20081230120756.GA5393@rhlx01.hs-esslingen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Dec 30, 2008 at 01:07:56PM +0100, Andreas Mohr wrote:
> On Mon, Dec 29, 2008 at 03:15:37PM -0800, Jeff Kirsher wrote:
> > He is referring to a patch to add support for devices which do not use
> > the MII interface which use an Intel MAC.  I have the patch in my
> > local tree and have been keeping it up-to-date.  I should have an
> > update on this patch after the New Year.
> 
> Thanks!
> 
> One idea worth pondering might be to provide a special struct
> mii_if_info hookup (fully emulated mdio_read()/write())
> for the case of the non-MII hardware types of this driver,
> thus eliminating any added penalty in the case of nicely MII-compliant
> hardware.
> But this should be tackled later, now let's better move on with eepro100
> (non-)plans...
> 
> Andreas Mohr

Given that 2.6.29-rc now actually has eepro100.c removed (since -rc3 or so)
and the current -rc6 e100.c does not contain non-MII parts, it looks like
2.6.29 proper will actually remove support for some PCI-based non-MII
e100 cards.

Thus I'd like to ask what should be done about this for real.
Of course we could consciously decide to simply skip e100.c support for those
non-MII cards entirely (hoping that they're not THAT wide-spread),
but obviously I'd semi-hate this (nevermind the fact that _locally_
I'd have to swap cards, too, which is somewhat more of a problem given an
older network requiring to be served by "combo" cards).

Simply spoken, it all boils down to actively deciding
what to do in the next, about-to-be _affected_, kernel version
about support for cards that an older, deprecated driver did support
and the new one doesn't.

Or one could just let things progress as-is and wait for
yet unknown (non-)amounts of scorching user feedback to arrive
after 2.6.29 has hit their machines ;)


My description in the mail above was meant to list things to be done
_after_ an initial non-MII support for e100.c has been added,
just for clarification.

Thanks,

Andreas Mohr

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H

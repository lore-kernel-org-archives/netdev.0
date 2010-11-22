From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/62] drivers/net: Use static const
Date: Mon, 22 Nov 2010 14:10:46 -0800
Message-ID: <1290463846.27683.36.camel@Joe-Laptop>
References: <cover.1290305773.git.joe@perches.com>
	<20101120.205059.193725921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ath5k-devel@lists.ath5k.org, libertas-dev@lists.infradead.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	users@rt2x00.serialmonkey.com, linux-kernel@vger.kernel.org,
	socketcan-core@lists.berlios.de, ath9k-devel@lists.ath9k.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20101120.205059.193725921.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, 2010-11-20 at 20:50 -0800, David Miller wrote: 
> From: Joe Perches <joe@perches.com>
> Date: Sat, 20 Nov 2010 18:38:01 -0800
> 
> > Using static const generally increases object text and decreases data size.
> > It also generally decreases overall object size.
> 
> Joe, I'm going to be frank and say that I'm not going to review and
> apply such a large chunk of networking patches.

Hi David.  No worries.

> Separation is cool, splitting up patches is cool to make review
> perhaps easier and more distributed.

I know you have ownership of netdev.  Thanks for doing all that
work.  You may not get enough feedback on the very good job that
you do at it.

I posted these patches not so much to get you to immediately pick
them up, but to get review from and/or notify the maintainers of
each of these subsystems.  I would have submitted them to Jiri
Kosina/trivial, but he asked me to post and track these style
patches separately and wait for a few weeks before submitting any
remaining patches not picked up by maintainers to him.

> It severely negatively effects my mood,

Can't have that...

> You also make this more difficult for me by not using GIT.

I do of course use git locally.  I have a public tree as well,
but I hardly update it.  I updated it recently for this.

These patches are available in:

  git://repo.or.cz/linux-2.6/trivial-mods.git 20101121_net_next_static_const

Perhaps I should ask Stephen Rothwell to include some trivial tree
branch like this in next.

> Even with patchwork helping me significantly, it's still a lot of work
> to apply large sets of patches.

I think that cc'ing netdev is always appropriate for netdev patches, but
maybe trivial@kernel.org could become linux-trivial@vger.kernel.org or
something like that.

Perhaps there could be some way to automatically mark these exceptionally
trivial patches as something like "not applicable" so they don't appear
on your personal queue.

> If I had to take in John Linville's
> wireless stuff without GIT I'd be banging my head on a wall.
> 
> And these incessant huge patch bombs also take time away from me for
> the things I'd like to at least occiasionally work on that involve
> more intellect than monkeying around with such mindless patches.

Establishing trust is always a long term thing.
Breaking trust is easy too.

Anyway, I think these patches are obvious and correct and can be
directly applied without significant risk.

I think the the issues are:

o should the nominal maintainers of the subsystems pick them up
o should these subsystem maintainers should be bypassed
o should the subsystem mailing lists be cc'd
o should these be pulled as a single changeset or multiples

I think that getting the nominal subsystem maintainers involved
is good, but perhaps not too necessary for these sorts of patches.

btw: it doesn't seem that, other than John Linville for wireless,
you currently pull from many (any?) other people.  Do let me know
if you'd consider pulling these sorts of changes from me.

$ git log --merges --since=2-years-ago drivers/net | grep "^Author: " | sort | uniq -c | sort -rn
    259 Author: David S. Miller <davem@davemloft.net>
    201 Author: Linus Torvalds <torvalds@linux-foundation.org>
     45 Author: John W. Linville <linville@tuxdriver.com>
     15 Author: Russell King <rmk@dyn-67.arm.linux.org.uk>
     15 Author: Ingo Molnar <mingo@elte.hu>
     14 Author: Benjamin Herrenschmidt <benh@kernel.crashing.org>
      7 Author: Russell King <rmk+kernel@arm.linux.org.uk>
      6 Author: Jiri Kosina <jkosina@suse.cz>
      4 Author: Reinette Chatre <reinette.chatre@intel.com>
      3 Author: Roland Dreier <rolandd@cisco.com>
      3 Author: James Morris <jmorris@namei.org>
      2 Author: Tony Lindgren <tony@atomide.com>
      2 Author: Grant Likely <grant.likely@secretlab.ca>
      1 Author: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
      1 Author: root <root@dyn-67.arm.linux.org.uk>
      1 Author: Paul Mackerras <paulus@samba.org>
      1 Author: Kevin Hilman <khilman@deeprootsystems.com>
      1 Author: James Bottomley <James.Bottomley@HansenPartnership.com>

> Thanks for your understanding.  Feel free to submit this stuff in
> smaller chunks, say ~10 patches at a time.

Let me know if you want to pull or want them in smaller chunks in
say a month from now.

cheers, Joe


------------------------------------------------------------------------------
Increase Visibility of Your 3D Game App & Earn a Chance To Win $500!
Tap into the largest installed PC base & get more eyes on your game by
optimizing for Intel(R) Graphics Technology. Get started today with the
Intel(R) Software Partner Program. Five $500 cash prizes are up for grabs.
http://p.sf.net/sfu/intelisp-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

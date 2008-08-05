From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Tue, 5 Aug 2008 10:05:17 -0400
Message-ID: <20080805140517.GA7819@tuxdriver.com>
References: <20080804193753.GA30345@tuxdriver.com> <20080804.150147.78586437.davem@davemloft.net> <20080805021710.GA21731@tuxdriver.com> <20080805.012814.215633850.davem@davemloft.net> <20080805232839.95235680.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3078 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083AbYHEOc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 10:32:26 -0400
Content-Disposition: inline
In-Reply-To: <20080805232839.95235680.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 11:28:39PM +1000, Stephen Rothwell wrote:
> Hi David,
> 
> On Tue, 05 Aug 2008 01:28:14 -0700 (PDT) David Miller
> <davem@davemloft.net> wrote:
> >
> > From: "John W. Linville" <linville@tuxdriver.com>
> > Date: Mon, 4 Aug 2008 22:17:10 -0400
> > 
> > > On Mon, Aug 04, 2008 at 03:01:47PM -0700, David Miller wrote:
> > > > I'm holding off on this pull until the list.h changes get so me lkml
> > > > ACKs.
> > > 
> > > Sure, np.  I created a "no-ath9k" branch in case you are feeling
> > > frisky -- it is the same except for omitting the list.h changes,
> > > the ath5k pci table change, and the new ath9k driver.
> > > 
> > > 	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git no-ath9k
> > > 
> > > Hth!
> > 
> > Due to the powerpc build failures the list.h stuff causes, I'm going
>              ^^^^^^^
> It was a sparc64 defconfig that failed due to the list.h changes.  The
> powerpc build only failed when I added an include of <linux/bug.h> to
> list.h.
> 
> The powerpc compiler got an internal error trying to compile the ath9k
> code - but I don't know if there is anything we can to do to the source
> to work around that.

FWIW I fixed-up the wireless-2.6 tree to reflect what davem pulled -- a
noop, but at least those patches shouldn't pollute -next tomorrow. :-)

John
-- 
John W. Linville
linville@tuxdriver.com

From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ath9k build failure
Date: Tue, 12 Aug 2008 09:21:48 -0400
Message-ID: <20080812132148.GC27672@tuxdriver.com>
References: <20080811162040.ed7b8ab7.sfr@canb.auug.org.au> <20080811164657.GE6128@tesla> <20080812133354.2eadf82d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@Atheros.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2561 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbYHLNcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 09:32:45 -0400
Content-Disposition: inline
In-Reply-To: <20080812133354.2eadf82d.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 01:33:54PM +1000, Stephen Rothwell wrote:
> Hi Luis,
> 
> On Mon, 11 Aug 2008 09:46:57 -0700 "Luis R. Rodriguez" <lrodriguez@atheros.com> wrote:
> >
> > On Sun, Aug 10, 2008 at 11:20:40PM -0700, Stephen Rothwell wrote:
> > > 
> > > Today's linux-next build (powerpc allyesconfig) failed like this:
> > > 
> > > drivers/net/wireless/ath9k/hw.c: In function 'ath9k_hw_spur_mitigate':
> > > drivers/net/wireless/ath9k/hw.c:4925: internal compiler error: in expand_expr_real_1, at expr.c:9199
> > > 
> > > This is a driver that is in Linus' tree and has no patches in the
> > > linux-next tree.
> > > 
> > > The original work around talked about applying the patch twice, so I
> > > applied the below patch.
> > 
> > this is also in wireless-testing. I also see this in linux-2.6
> > under b08cbcd4546445740c2a04291204b56f8baf7be2. Not sure how this didn't
> > get through linux-next.
> 
> That is only the first application of the patch, my patch is a fix of a
> second instance of the same code.  See Adrian's post.

My bad...I'll fix it up w/ the next batch of fixes...

John
-- 
John W. Linville
linville@tuxdriver.com

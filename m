From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Mon, 15 Sep 2014 14:45:47 -0400
Message-ID: <20140915184546.GB3891@tuxdriver.com>
References: <1403091974.1984.102.camel@x220>
 <1409911856.7832.9.camel@x220>
 <CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ@mail.gmail.com>
 <1409916824.7832.20.camel@x220>
 <CAHNKnsQ1gt=DRBTd9Q9yos1idqmXMepEPvhm8a7unP-whzNAgg@mail.gmail.com>
 <20140909182734.GJ29412@tuxdriver.com>
 <CAHNKnsQ8G3ZFHshq7wOqex1J6DbVD5uHVAyvs+aDC2Znk5zWww@mail.gmail.com>
 <541037D2.7060007@gmail.com>
 <CAHNKnsTtqz10c=vV-f10awLanYZzom3kJ1cO5xgTGs-t3O9NYg@mail.gmail.com>
 <20140911192146.GC22872@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jirislaby@gmail.com>, Paul Bolle <pebolle@tiscali.nl>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Oleksij Rempel <linux@rempel-privat.de>,
	Richard Weinberger <richard@nod.at>,
	Jonathan Bither <jonbither@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	ath5k-devel@venema.h4ckr.net, open@hauke-m.de,
	"list@hauke-m.de:NETWORKING DRIVERS" <list@hauke-m.de>,
	"antonynpavlov@gmail.com" <antonynpavlov@gmail.com>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44080 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbaIOTAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:00:17 -0400
Content-Disposition: inline
In-Reply-To: <20140911192146.GC22872@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2014 at 03:21:46PM -0400, John W. Linville wrote:
> On Wed, Sep 10, 2014 at 04:19:21PM +0400, Sergey Ryazanov wrote:
> > 2014-09-10 15:36 GMT+04:00, Jiri Slaby <jirislaby@gmail.com>:
> > > On 09/10/2014, 12:33 PM, Sergey Ryazanov wrote:
> > >> 2014-09-09 22:27 GMT+04:00, John W. Linville <linville@tuxdriver.com>:
> > >>> On Fri, Sep 05, 2014 at 04:02:10PM +0400, Sergey Ryazanov wrote:
> > >>>> 2014-09-05 15:33 GMT+04:00 Paul Bolle <pebolle@tiscali.nl>:
> > >>>>> Hi Sergey,
> > >>>>>
> > >>>>> On Fri, 2014-09-05 at 15:12 +0400, Sergey Ryazanov wrote:
> > >>>>>> 2014-09-05 14:10 GMT+04:00, Paul Bolle <pebolle@tiscali.nl>:
> > >>>>>>> On Wed, 2014-06-18 at 13:46 +0200, Paul Bolle wrote:
> > >>>>>>>> Having this conversation every rc1 is getting a bit silly. Could
> > >>>>>>>> Jiri
> > >>>>>>>> e.a. perhaps set some specific deadline for ATHEROS_AR231X to be
> > >>>>>>>> submitted?
> > >>>>>>>
> > >>>>>>> I waited until rc3. Have you seen any activity on this front? If
> > >>>>>>> not,
> > >>>>>>> should I resend the patch that removes the code in mainline that
> > >>>>>>> depends
> > >>>>>>> on ATHEROS_AR231X (ie, AHB bus support)?
> > >>>>>>>
> > >>>>>> Recent activity always could be found in [1]. Now I finish another
> > >>>>>> one
> > >>>>>> round of cleanups and have a plan to fix several things (you can
> > >>>>>> always find something that you really want to improve). But if you
> > >>>>>> insist I could immediately switch to "send upstream" mode. And seems
> > >>>>>> that this would be better approach.
> > >>>>>>
> > >>>>>> 1. https://dev.openwrt.org/log/trunk/target/linux/atheros
> > >>>>>
> > >>>>> And where can the related PULL requests or patch submissions be found?
> > >>>>>
> > >>>> I have not sent patches yet, since I thought that it would be easier
> > >>>> to cleanup them in openwrt tree and then send them upstream.
> > >>>
> > >>> That excuse has worn a bit thin.  Perhaps Paul should repost his
> > >>> removal and you can add a revert to the start of your patch series?
> > >>>
> > >> As for me, I do not like such flapping
> > >
> > > Agreed in case what you have is in a good enough shape. You (and also
> > > others) can still clean up the code in upstream too. So, if it is
> > > mergeable, send it for upstream inclusion now, otherwise I am all for
> > > John to apply the Paul's patch.
> > 
> > Two days is the last deadline :)
> > 
> > > The unused code has been a way too long
> > > in the tree now.
> > 
> > Code actively used in owrt firmware and its forks.
> 
> Is this code coming or not?  When can I expect to see it posted?

FYI -- Sergey posted a series to linux-mips on 14 September 2014 that
touches the symbol in question.  For whatever reason, it is posted
there as RFC.

Does this satisfy the interested parties??

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

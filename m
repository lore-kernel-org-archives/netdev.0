From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] MAINTAINERS: Add networking wireless drivers section
Date: Tue, 28 Jul 2009 11:27:07 -0700
Message-ID: <1248805627.18284.11.camel@Joe-Laptop.home>
References: <Pine.LNX.4.64.0907281753540.28189@ask.diku.dk>
	 <20090728.103044.179053537.davem@davemloft.net>
	 <1248804397.18284.5.camel@Joe-Laptop.home>
	 <20090728111552.528a2c9a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>, julia@diku.dk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1304 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbZG1S16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 14:27:58 -0400
In-Reply-To: <20090728111552.528a2c9a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-28 at 11:15 -0700, Randy Dunlap wrote:
> On Tue, 28 Jul 2009 11:06:37 -0700 Joe Perches wrote:
> > On Tue, 2009-07-28 at 10:30 -0700, David Miller wrote:
> > > Wireless patches need to be CC:'d to linux-wireless so that
> > > John Linville can notice and pick them up
> > Signed-off-by: Joe Perches <joe@perches.com>
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index ebc2691..0574aad 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -4186,6 +4186,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> >  S:	Odd Fixes
> >  F:	drivers/net/
> >  
> > +NETWORKING WIRELESS DRIVERS
> > +L:	linux-wireless@vger.kernel.org
> > +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> > +S:	Odd Fixes
> > +F:	drivers/net/wireless/
> > +
> 
> Already have this:
> 
> NETWORKING [WIRELESS]
> P:	John W. Linville
> M:	linville@tuxdriver.com
> L:	linux-wireless@vger.kernel.org
> T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> S:	Maintained
> F:	net/wireless/
> F:	include/net/ieee80211*
> F:	include/linux/wireless.h

That section does not include drivers/net/wireless/

I believe John Linville isn't maintaining all the
wireless drivers, he's acting as a gatekeeper in
a similar role as DavidM for drivers/net/.

The patch above means scripts/get_maintainer.pl can
use the linux-wireless@vger list email address for
any change in driver/net/wireless/



From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Wed, 18 Jul 2007 18:21:56 -0700 (PDT)
Message-ID: <20070718.182156.17251646.davem@davemloft.net>
References: <20070718153449.GA6625@tuxdriver.com>
	<20070718.153248.82378078.davem@davemloft.net>
	<20070719004510.GA5618@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51423
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935426AbXGSBV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 21:21:57 -0400
In-Reply-To: <20070719004510.GA5618@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 18 Jul 2007 20:45:10 -0400

> On Wed, Jul 18, 2007 at 03:32:48PM -0700, David Miller wrote:
> > From: "John W. Linville" <linville@tuxdriver.com>
> > Date: Wed, 18 Jul 2007 11:34:49 -0400
> > 
> > > On Tue, Jul 17, 2007 at 08:17:16PM -0700, David Miller wrote:
> > > > From: "John W. Linville" <linville@tuxdriver.com>
> > > > Date: Tue, 17 Jul 2007 22:16:07 -0400
> > > > 
> > > > > A few more for 2.6.23...individual patches available here:
> > > > > 
> > > > >   http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem
> > > > 
> > > > What about this warning which I reported to you right after the last
> > > > merge?  Did this get fixed?
> > > > 
> > > > net/mac80211/ieee80211.c:4989: warning: comparison of distinct pointer types lacks a cast
> > > > 
> > > > Please fix that up first, then I'll pull from your tree.
> > > 
> > > Fair enough! :-)
> > 
> > As I pointed out to Jiri, you need to spell out the complete type
> > warning fix, rather than just "unsigned".
> 
> I went ahead and made that change, including the mysterious space after
> "unsigned int " that seems to be common practice.  I had considered
> asking for this before...oh well, it's there now! :-)
> 
> BTW, I also included an extra patch from Michael Wu which helps to
> avoid some possible deadlocks when shutting down an interface.

Pulled, thanks John.

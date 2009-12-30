From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2009-12-30
Date: Wed, 30 Dec 2009 13:56:25 -0800 (PST)
Message-ID: <20091230.135625.193704457.davem@davemloft.net>
References: <20091230211024.GA6706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751896AbZL3V4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 16:56:22 -0500
In-Reply-To: <20091230211024.GA6706@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 30 Dec 2009 16:10:25 -0500

> I had to pull wireless-2.6 into wireless-next-2.6 in order to resolve
> a conflict in the libertas driver.  Since wireless-next-2.6 was cloned
> from net-next-2.6 at a point before it was reopened for 2.6.34, the
> pull of wireless-2.6 (which is cloned from a net-2.6 from the same
> period) brought along some non-wireless bits that were not already
> in wireless-next-2.6.  However, I did check and made sure that those
> bits are already present in net-next-2.6.  Anyway, my point is that
> I don't have enough git foo to easily generate a pull request that
> represents the actual state of affairs without rebasing or doing some
> other messy thing.  I think/hope this is another one-time transition
> pain with the new wireless tree management policies...

All you have to do is set your origin correctly.  And then
generate your pull requests relative to that.

Your origin should be net-next-2.6   So if it's there in your
.git/config file all you have to do is "git request-pull origin ..."

If you're merging between wireless-2.6 and wireless-next-2.6
that's perfect.  It actually saves me work.  I'll figure things
out when I pull in your changes.

Most of your workflow (like mine) should be:

1) git fetch origin

2) git request-pull origin ...

If there are major net-next-2.6 conflicts to resolve (you can
determine this via "git checkout -b merge-test origin; git pull
master") then simply "git pull origin" into your master.

Then you simply let me know you did this, and it was to resolve
a major conflict with the net-next-2.6 origin.

> So, the net of the garbled paragraph above is that despite the messy
> report generatd by 'git request-pull' below, when you pull from
> wireless-next-2.6 into net-next-2.6 you will only get actual wireless
> changes!  I hope you can overlook the apparent discrepencies in the
> report below and rely on the actual pull results instead. :-)

It looks good from here so far.  I'll run some build tests and
then push this out.  That'll take a while since I'm about to head
out, so don't expect it for a few hours.

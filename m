From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 01/20] net: slight optimization of addr compare for
 some modules
Date: Tue, 24 Dec 2013 07:05:17 -0800
Message-ID: <1387897517.2259.41.camel@joe-AO722>
References: <52B96F9B.4020806@huawei.com>
	 <1387894944.2259.31.camel@joe-AO722> <52B99BB9.9030201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0149.hostedemail.com ([216.40.44.149]:59506 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752301Ab3LXPFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 10:05:21 -0500
In-Reply-To: <52B99BB9.9030201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-24 at 22:35 +0800, Ding Tianhong wrote:
> =E4=BA=8E 2013/12/24 22:22, Joe Perches =E5=86=99=E9=81=93:
> > On Tue, 2013-12-24 at 19:27 +0800, Ding Tianhong wrote:
> >> Use possibly more efficient ether_addr_equal_unaligned
> >> and ether_addr_equal to instead of memcmp.
> >=20
> > A negative of adding so many different drivers in a single
> > patch is that you miss sending patches to the named maintainers.
> >=20
> > Most of these below have separate individual maintainers.
>
> you mean that I should send below by separate patch?

I think yes,

You can send them to netdev, but cc'ing the named
maintainers is a polite thing to do.

Sending individual patches can make it easier for
maintainers to review the bits that are specific
to their projects without having to wade through
other changes that aren't relevant to them.

> It seemed that I=20
> misunderstood, I use the ./script/getmainter and found the only maint=
ainer
> is David, and others are support, so maybe I was wrong, but it really=
 a big
> patchset, could I send them by seperate patchset? I think it could be=
 more
> clearly.

=46rom the MAINTAINERS file:
	S: Status, one of the following:
	   Supported:	Someone is actually paid to look after this.
	   Maintained:	Someone actually looks after it.
	   Odd Fixes:	It has a maintainer but they don't have time to do
			much other than throw the odd patch in. See below..
	   Orphan:	No current maintainer [but maybe you could take the
			role as you write your new code].
	   Obsolete:	Old code. Something tagged obsolete generally means
			it has been replaced by a better system and you
			should be using that.

So "supported" is "higher/better" than "maintained".

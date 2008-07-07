From: "John W. Linville" <linville@redhat.com>
Subject: Re: Oops/Warning report of the week of July 4th 2008
Date: Mon, 7 Jul 2008 11:55:52 -0400
Message-ID: <20080707155552.GF28109@redhat.com>
References: <486EA0D6.2040504@linux.intel.com> <20080704222341.GB9792@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Becker <stefan.becker@nokia.com>
To: Dave Jones <davej@redhat.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Linus Torvalds <to
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752677AbYGGP4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 11:56:10 -0400
Content-Disposition: inline
In-Reply-To: <20080704222341.GB9792@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 04, 2008 at 06:23:41PM -0400, Dave Jones wrote:
> On Fri, Jul 04, 2008 at 03:14:46PM -0700, Arjan van de Ven wrote:
>  
>  > The stats look very similar to last week; Fedora released a 2.6.25.9 based
>  > kernel upgrade, which led to a new sighting (at rank 12): the rt25xx wireless
>  > driver is calling flush_workqueue() with a NULL parameter in some cases.
>  > There has been a lot of thrash about the last report with regard to inclusion of wireless.git
>  > into the Fedora kernel rpms. As an observer I can say that it's both a blessing and a bog.
>  > It's a blessing in that this allows bugs to show up early before wireless.git hits mainline
>  > (as an example: this is the third or fourth fedora rpm upgrade in a row that showed new and exciting
>  > oopses/warnings due to rt25xx... as a result of very active development). It's a bog in that
>  > it may expose users to not-quite-ready code. So far it seems the Fedora kernel maintainers are happy
>  > enough with the overall balance that they continue the practice.
> 
> I actually think we need to scale things back a notch wrt pushing
> wireless.git bits to users of released distros.  The recent disaster
> in wireless caused a shitstorm in bugzilla that we never even saw
> in rawhide.  A clear sign that we're pushing things too fast to users.

Well I agree that we are pushing things too quickly to users.
However I believe that improper use of Bodhi is at least as much to
blame as I am.

FWIW, I'd like to point out that a user (Stefan Becker) helped
to sort-out my "human error" screw-up (i.e. not some buggy patch
from upstream) that caused the latest flurry regarding busted TKIP
for mac80211.  IMHO this is in the best traditions of open source,
and a credit to our community.
 
> It's great that we're getting this stuff tested, but at the same time,
> it doesn't give a great impression, and makes users reluctant to always
> apply the latest updates if the last time around they have to deal with
> this kind of fallout.

When patches went-in more slowly, we still hit nearly as many problems.
Only then it took longer to solve them because we (i.e. Fedora) were
so far behind what the upstream developers were doing that we couldn't
get their attention.  As it stands, Fedora gets quick attention even
from developers who use other distros.

Still, maybe we are approaching a point where it is prudent to slow
some things down for Fedora.  I sent a proposal along those lines
to fedora-kernel-list.  I just don't think we should be too quick
to drop the goodness we are getting by staying close to upstream on
wireless.  And in either event, we may need to find another monkey,
because I've been finding it hard enough to keep-up with dumping
patches to Fedora as-is.

John
-- 
John W. Linville
linville@redhat.com

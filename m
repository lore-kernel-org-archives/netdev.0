From: Andrew Morton <akpm@osdl.org>
Subject: Re: Please pull upstream-fixes branch of wireless-2.6
Date: Thu, 20 Apr 2006 01:57:52 -0700
Message-ID: <20060420015752.01d36087.akpm@osdl.org>
References: <20060420011232.GA9268@tuxdriver.com>
	<200604201051.03881.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, netdev@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18058 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750735AbWDTI6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 04:58:53 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200604201051.03881.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb@bu3sch.de> wrote:
>
> On Thursday 20 April 2006 03:12, John W. Linville wrote:
> >       bcm43xx: fix dyn tssi2dbm memleak
> >       bcm43xx: fix pctl slowclock limit calculation
> >       bcm43xx: sysfs code cleanup
> 
> These are already in -mm and on their way into linus's tree.

I don't send netdev patches to Linus except under unusual circumstances. 
I'd expect these patches to go upstream via John or Jeff.

> Is it possible to cause problems?

Nope, I'll just drop then when they appear in a git tree.

And I really need to find a way of getting git-wireless into -mm.  Problem
is, it's based off git-netdev-all and when John's tree is synced to a later
version of Linus's tree than Jeff's tree, all hell breaks loose at my end. 
Junio and I weren't able to work out a way of extracting the jeff->john
diffs so I gave up.

Probably, I'll need to actually do a git merge, generate the diff then
throw away the resulting git tree.  Or something.  I've avoided doing git
merges because I'm dealing with 58 trees and I suspect I'd go insane.

> If not, fine. If yes, we need some clearly defined rules where
> to put patches and a clearly defined statement of how often
> patches are pushed upstream.

Because I don't carry git-wireless I don't have visibility of when John has
merged something.  Ordinarily you'd have seen me drop the patches again
when they popped up in John's tree.



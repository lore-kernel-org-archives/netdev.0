From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2010-02-10
Date: Wed, 10 Feb 2010 15:37:35 -0500
Message-ID: <20100210203734.GE3286@tuxdriver.com>
References: <20100210201953.GC3286@tuxdriver.com> <20100210.122540.149553948.davem@davemloft.net> <20100210203227.GD3286@tuxdriver.com> <20100210.123503.129355851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mb@bu3sch.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100210.123503.129355851.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 10, 2010 at 12:35:03PM -0800, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 10 Feb 2010 15:32:28 -0500
> 
> > On Wed, Feb 10, 2010 at 12:25:40PM -0800, David Miller wrote:
> >> From: "John W. Linville" <linville@tuxdriver.com>
> >> Date: Wed, 10 Feb 2010 15:19:54 -0500
> >> 
> >> > On Wed, Feb 10, 2010 at 11:36:58AM -0800, David Miller wrote:
> >> >> From: Johannes Berg <johannes@sipsolutions.net>
> >> >> Date: Wed, 10 Feb 2010 20:15:37 +0100
> >> >> 
> >> >> > It was intentional -- that sdev doesn't even have an irq member, but
> >> >> > nobody ever noticed because of the wrong ifdef.
> >> >> 
> >> >> Ok, then this needs to be explained in the commit message.
> >> > 
> >> > OK...mind if I just revert the current version and ask Michael to
> >> > resubmit with an appropriate changelog entry?
> >> 
> >> Have you pulled this tree into others already?  Why not
> >> just pop out the commit and fix it's commit message, then
> >> reapply?
> >> 
> >> Having the revert commit in there is really stupid just for this.
> > 
> > I have it pulled into wireless-next-2.6 to fix a merge conflict (from
> > a latter commit).  It is also pulled into wireless-testing but that
> > is obviously less of an issue.
> 
> Ok, forget this, I'll just pull it in as-is.
 
K, thx!

> But we have to have a better system to handle cases where I
> don't like a change you're asking me to pull in and I want
> changes made to it.
> 
> If you want to push stuff into wireless-next-2.6, get it into
> my tree first.  That way we can tidy things up before it
> propagates.

Yeah, I was trying to be proactive about the merge conflicts and
avoid the emails about the conflicts in -next.  But I guess that
isn't a huge deal anyway, so I'll be a bit more cautious in the future.

Thanks!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

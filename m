From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Tue, 17 Apr 2007 14:34:42 -0400
Message-ID: <20070417183442.GE8633@tuxdriver.com>
References: <20070323003116.GC2712@bougret.hpl.hp.com> <1175508410.23438.75.camel@johannes.berg> <20070417170820.GB22372@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070417170820.GB22372-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2007 at 10:08:20AM -0700, Jean Tourrilhes wrote:
> On Mon, Apr 02, 2007 at 12:06:50PM +0200, Johannes Berg wrote:
> > 
> > Jean Tourrilhes wrote :
> > > 	Johannes Berg discovered that kernel space was leaking to
> > > userspace on 64 bit platform. He made a first patch to fix that. This
> > > is an improved version of his patch.
> > > 	This was tested on 2.6.21-rc4. Would you mind pushing that
> > > upstream ?
> > 
> > Just FYI. This patch applies with rejects in net/core/rtnetlink.c and
> > net/core/wireless.c to wireless-dev. The changes in those two files can
> > be ignored completely since they affect only the removed
> > wext-over-netlink interface.
> > 
> > johannes
> 
> 	I'm sorry to have to write this e-mail. But this incident is
> completely opposed to the ideal of FreeSoftware/OpenSource and
> demonstrate some of the bad politics happening in Linux.
> 
> 	First, I'm the current active maintainer of the
> wext-over-netlink interface, and nobody bothered to even 'inform' me
> about its removal, let alone consult with me.

Honestly, most of us thought you weren't interested.

> 	This shows a complete lack of courtesy and a total disrespect
> to the concept of maintainer, basically some people are just second
> class citizens.

I'm sorry that you are upset.  I do not believe any disrespect was
intended.

> 	Second, there is no technical justification to such decision,
> it's just plain politics. I would agree that for the vast majority of
> people, this API was useless, as any work in progress. But, it is
> maintained (by me), it is not causing any technical issue, for those
> people it's not compiled in (i.e. no bloat), it is not causing bugs
> and not preventing other code to be merged in the kernel.
> 	Therefore a purely politic decision.

I would not call it politics, but I do not want to split hairs.

This API was controversial and mostly unwelcome from the start.
It was ridiculed as "ioctls over netlink" at the last kernel summit.
It is widely regarded as less of a solution and more of an extension
to a problem.

One of the objections to having merged the API was that _if_ it were
to gain users then we would have to carry that maintenance burden
ad infinitum.  This fear was already beginning to be confirmed by the
efforts at maintaining WE compatibility in cfg80211.  Since there were
(thankfully) still no users and only compatibility headaches from
maintaining it, Johannes wanted to remove the code, and I consented
to his request.

I wish you would not view this as a personal issue.  Your contributions
are certainly welcome in general.  We just don't see any benefit from
keeping this code around as we move forward.

Again, I am terribly sorry that this was a surprise to you.  I will be
sure to communicate with you directly should another such issue arise.

> 	By the way : don't bother replying to this e-mail, nothing
> good will come of it.

Hopefully that isn't totally true...

Regards,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org

From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Tue, 17 Apr 2007 10:08:20 -0700
Message-ID: <20070417170820.GB22372@bougret.hpl.hp.com>
References: <20070323003116.GC2712@bougret.hpl.hp.com> <1175508410.23438.75.camel@johannes.berg>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1175508410.23438.75.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2007 at 12:06:50PM +0200, Johannes Berg wrote:
> 
> Jean Tourrilhes wrote :
> > 	Johannes Berg discovered that kernel space was leaking to
> > userspace on 64 bit platform. He made a first patch to fix that. This
> > is an improved version of his patch.
> > 	This was tested on 2.6.21-rc4. Would you mind pushing that
> > upstream ?
> 
> Just FYI. This patch applies with rejects in net/core/rtnetlink.c and
> net/core/wireless.c to wireless-dev. The changes in those two files can
> be ignored completely since they affect only the removed
> wext-over-netlink interface.
> 
> johannes

	I'm sorry to have to write this e-mail. But this incident is
completely opposed to the ideal of FreeSoftware/OpenSource and
demonstrate some of the bad politics happening in Linux.

	First, I'm the current active maintainer of the
wext-over-netlink interface, and nobody bothered to even 'inform' me
about its removal, let alone consult with me.
	This shows a complete lack of courtesy and a total disrespect
to the concept of maintainer, basically some people are just second
class citizens.

	Second, there is no technical justification to such decision,
it's just plain politics. I would agree that for the vast majority of
people, this API was useless, as any work in progress. But, it is
maintained (by me), it is not causing any technical issue, for those
people it's not compiled in (i.e. no bloat), it is not causing bugs
and not preventing other code to be merged in the kernel.
	Therefore a purely politic decision.

	Now, I've got a problem with your attitude in this matter,
Johannes. It's now the second time you remove features from code I
maintain by pure fiat, and you have engaged in a long running FUD
campain about my code. This is totally disgraceful of a Linux
maintainer, and you should know it.
	If the only way you have to promote your code is by actively
destroying my code, then you have a real issue. Your code should stand
on its own merit, without the need of attacking other people's work
and playing political tricks.
	I hope you will note that I never disparaged your code, I
never prevented its inclusion in Linux and I never attempted to
control the Linux Wireless space and left plenty of space for new
developpers.

	You still have a lot to learn, like all of us. You still don't
understand Wireless Extensions (as your FUD shows) and why it's still
so popular despite all its warts. You don't get the value of not
burning bridges with other developpers and professional conduct.

	By the way : don't bother replying to this e-mail, nothing
good will come of it.

	Have fun...

	Jean

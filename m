From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Wed, 18 Apr 2007 01:34:50 +0200
Message-ID: <200704180134.50571.mb@bu3sch.de>
References: <20070323003116.GC2712@bougret.hpl.hp.com> <1175508410.23438.75.camel@johannes.berg> <20070417170820.GB22372@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070417170820.GB22372-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 April 2007 19:08, Jean Tourrilhes wrote:
> 	I'm sorry to have to write this e-mail. But this incident is
> completely opposed to the ideal of FreeSoftware/OpenSource and
> demonstrate some of the bad politics happening in Linux.
> 
> 	First, I'm the current active maintainer of the
> wext-over-netlink interface, and nobody bothered to even 'inform' me
> about its removal, let alone consult with me.
> 	This shows a complete lack of courtesy and a total disrespect
> to the concept of maintainer, basically some people are just second
> class citizens.
> 
> 	Second, there is no technical justification to such decision,
> it's just plain politics. I would agree that for the vast majority of
> people, this API was useless, as any work in progress. But, it is
> maintained (by me), it is not causing any technical issue, for those
> people it's not compiled in (i.e. no bloat), it is not causing bugs
> and not preventing other code to be merged in the kernel.
> 	Therefore a purely politic decision.

It is _only_ about replacing obsolete code by code that obsoleted it.
That happens all the time. Look at the process scheduler and compare
it to 2.4, for example.

We want to reduce the maintainance burden. Nothing more.
If we remove unused code (which WEXT-NL is), then we don't have to
write compatibility code to support it in future.
Why wait with removal until we can't anymore (when people use it)?

> 	Now, I've got a problem with your attitude in this matter,
> Johannes. It's now the second time you remove features from code I
> maintain by pure fiat, and you have engaged in a long running FUD
> campain about my code. This is totally disgraceful of a Linux
> maintainer, and you should know it.
> 	If the only way you have to promote your code is by actively
> destroying my code, then you have a real issue. Your code should stand
> on its own merit, without the need of attacking other people's work
> and playing political tricks.
> 	I hope you will note that I never disparaged your code, I
> never prevented its inclusion in Linux and I never attempted to
> control the Linux Wireless space and left plenty of space for new
> developpers.
> 
> 	You still have a lot to learn, like all of us. You still don't
> understand Wireless Extensions (as your FUD shows) and why it's still
> so popular despite all its warts. You don't get the value of not
> burning bridges with other developpers and professional conduct.

I'd say nobody but you does fully understand WEXT. Somebody might
call that either a design issue, or a documentation issue.
I personally make both issues responsible for this.

-- 
Greetings Michael.

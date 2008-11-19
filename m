From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Wed, 19 Nov 2008 09:39:19 -0500
Message-ID: <20081119143919.GA3485@tuxdriver.com>
References: <20081119000719.GA19756@tuxdriver.com> <1ba2fa240811182246m17a6baf0ybde19af030a65819@mail.gmail.com> <1ba2fa240811190134u7974a840i532e8ed0e18f8c72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1ba2fa240811190134u7974a840i532e8ed0e18f8c72-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2008 at 11:34:37AM +0200, Tomas Winkler wrote:
> On Wed, Nov 19, 2008 at 8:46 AM, Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Wed, Nov 19, 2008 at 2:07 AM, John W. Linville
> > <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:

> >>      mac80211: remove ieee80211_notify_mac
> >>      iwlagn: fix RX skb alignment
> >
> > IMHO its premature pushing ttese 2 patches up, they came in yestrday
> > and nobody here has run tthe code
 
Well, thanks for your opinion.  Here is mine:

The iwlwifi drivers have been hitting these problems for months,
and I have seen no effort by your team to address the problems.
It is possible that your team is working on them behind closed doors
and will eventually throw something over the wall to us.  I'm tired
of waiting for that, and I imagine that hordes of iwlagn users are
tired of waiting as well.

Johannes has presented us with plausible fixes, and people are
reporting that the patches work for them.  I can merge these patches,
or wait/hope/pray for some to come from your team.  Experience suggests
that if fixes do come from your team that they will either be buried
in some monster patch that largely addresses something else, or
that the patches will arrive with a changelog that is terse and/or
unintelligble.  Subsequently, I am not optimistic about waiting.

I think Johannes cited four different bugzilla.kernel.org entries
between those two patches.  What is your team doing to address
those bugs?

Obviously, I still think that those patches should be merged.

> Just checked our bug database,  the ieee80211_notify_mac was
> introduced mainly to overcome HW bug when
> receiver become deaf  in heavy traffic such as ftp in noisy
> environment. Otherwise reconnection was too slow to keep ftp going. We
> need to check whether we are still hitting this before applying
> removal this function

You are welcome to submit patches that address your hardware issue
and which do not introduce locking problems.

Thanks,

John
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "Jouni Malinen" <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Fri, 9 Mar 2007 15:19:22 -0800
Message-ID: <20070309231922.GF24143@devicescape.com>
References: <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <1173393326.3831.21.camel@johannes.berg> <20070309213531.GA28070@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070309213531.GA28070-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 01:35:31PM -0800, Jean Tourrilhes wrote:

> 	It's not as bad as it look like. All userspace programs
> nowadays use either the iwlib or wpa_supplicant. For example,
> NetworkManager gets its stuff through wpa_supplicant, and kdenetwork
> uses iwlib. So, in essence, there is only two places to fix.
> 	Which is why I would like to hear from Jouni.

How confident are you of this being the full set? I did not use iwlib
for two reasons: its license and it not being available (at least at
that point in time) by default in many Linux distros. I would expect
someone else having the same reasons, but I have to admit that I have
not looked into this at all, so this is only a guess.

> 	By the way, I've just released version 29.pre16 which has a
> better band aid. It fixes bugs of the previous version and is more
> forward compatible (i.e. it's compatible with option 2).

Hmm.. What should I look as the description of the latest proposed
workaround? I was kind of hoping to see a nice description of the
problem and proposed change in couple of paragraphs of text.. ;-)
Anyway, I can see two changes when I diff wireless tools 29.pre14 and
pre15 that are clearly related to this. Diff of pre14 vs. pre16 or pre15
vs. pre16 includes more changes and some of them do not seem to be
related to issue.

Unfortunately I do not have access to any system to test this
workaround, so I cannot easily test this myself.

-- 
Jouni Malinen                                            PGP id EFC895FA

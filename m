From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 8 Mar 2007 11:13:22 -0800
Message-ID: <20070308191322.GA24598@bougret.hpl.hp.com>
References: <1173144447.15891.93.camel@johannes.berg> <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173380909.3248.52.camel@johannes.berg>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1173380909.3248.52.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 08:08:29PM +0100, Johannes Berg wrote:
> On Thu, 2007-03-08 at 10:49 -0800, Jean Tourrilhes wrote:
> 
> > 	A proper fix would involve forcing the alignement in the
> > kernel. Unfortunately, that would break 64bit->64bit configs. I think
> > I can build a workaround for this in iwlib.
> 
> Not easily I think. You'd have to get something that has a well-defined
> result and see whether padding is present or not. The MAC address might
> be good enough (due to len being 24 instead of the expected 20) though.
> Thing is that it's really hard to figure out (even at runtime) whether
> the kernel and machine are 64 or 32-bits.

	I'm looking into that. The good thing is that we have
redundant information, so we can check that things don't match. It's a
bit more complex because some of those take variable parameters.

> I'd think this is a kernel bug and 32-bit userspace should rightfully be
> able to expect 32-bit aligned structs, no? Actually fixing it in the
> kernel would not be trivial though.

	What we could do is have every 64 bit kernel return things on
a 32 bit boundary, irrespective of userspace used. That would break
current 64 bit userspace.

> johannes

	Thanks !

	Jean

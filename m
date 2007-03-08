From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 8 Mar 2007 14:36:22 -0800
Message-ID: <20070308223621.GB24960@bougret.hpl.hp.com>
References: <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <1173392526.3831.12.camel@johannes.berg>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1173392526.3831.12.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 11:22:06PM +0100, Johannes Berg wrote:
> On Thu, 2007-03-08 at 14:11 -0800, Jean Tourrilhes wrote:
> 
> > 	This is exactly what I was pointing out earlier. Well,
> > actually, there may be ways of fixing it in the kernel, but that would
> > be real ugly, and I don't want to go there.
> 
> Yeah, it would be extremely ugly and involve a lot of copying around
> when the app actually receives the data.
> 
> > 	I've just released wireless_tools.29.pre15.tar.gz. This is
> > supposed to include a "band-aid" for that problem. To the best of my
> > knowledge, it should catch the problem and not introduce false
> > positive. I would be glad if you guys would have a quick look into it,
> > because obviously I can't test it.
> 
> I looked at the diff between pre14 and pre15 but have to admit that I
> don't understand the code change.

	I must admit the fix is ugly.

> Unfortunately I can't test this until
> the 20th earliest so it'd be good if someone else could test this.

	Ok.

> Btw, could you look at the information leak patch I posted? We really
> need to get that fix (or another appropriate one) out asap.

	IMHO this does not have the same urgency. I'll see if we could
avoid copying, because the dest buffer is already zero filled.

> johannes

	Have fun...

	Jean

From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Tue, 6 Mar 2007 17:42:48 -0800
Message-ID: <20070307014248.GA20360@bougret.hpl.hp.com>
References: <1173144447.15891.93.camel@johannes.berg> <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200703061943.07350.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 07:43:06PM +0100, Michael Buesch wrote:
> > 
> > 	Yep, and it's even in fs/compat_ioctl.c. Hint, hint ;-)
> 
> Ok, it is wrapping the following ioctls:
> 
> HANDLE_IOCTL(SIOCGIWRANGE, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWTHRSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWTHRSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWAPLIST, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWSCAN, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWESSID, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWESSID, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWNICKN, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)
> 
> What about SIOCSIWSCAN, SIOCSIWENCODEEXT, SIOCGIWENCODEEXT
> and some others that also use iw_point?

	Yep, good point.
	SIOCSIWSCAN is up there. I did not realise that all the WPA
ioctls are missing. That's easy enough to fix, remember that you have
the full description of the ioctls in wireless.c.
	I'll try to do a patch if I find 5 min, but feel free to
forward something to John L.
	Thanks a lot !

> Greetings Michael.

	Jean

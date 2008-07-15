From: Nicolas Pitre <nico-mo2vmkxb4K0@public.gmane.org>
Subject: Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Tue, 15 Jul 2008 14:14:18 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0807151404530.12484@xanadu.home>
References: <20080709190915.GA8238@tuxdriver.com>
 <69e28c910807100912h30fcb57fpb4fb48b95c640f77@mail.gmail.com>
 <200807101815.27204.mb@bu3sch.de>
 <1216142191.6039.113.camel@localhost.localdomain>
 <alpine.LFD.1.10.0807151323570.12484@xanadu.home>
 <1216144711.13411.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	=?ISO-8859-15?Q?Stefanik_G=E1bor?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1216144711.13411.18.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2008, Dan Williams wrote:

> Some of the issues with the current Marvell 83xx GPL drivers that have
> gotten out are (a) code style, (b) lots of commented out stuff that's
> never used, (c) OS abstraction that's unnecessary on Linux, (d) doesn't
> use mac80211, and (e) uses private ioctls.  So hopefully you're writing
> a new 83xx driver from scratch :)

Yes, this is all from scratch.  The objective for this work is to be 
"mainlinable".

> We cleaned up a lot of stuff for the OLPC 8388 libertas driver, but
> unfortunately we never were able to get the Marvell 8388 team onboard,
> and so they just went off and kept working on their driver and didn't
> really move the upstream libertas driver forward at all.

Libertas is a rather different beast.


Nicolas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

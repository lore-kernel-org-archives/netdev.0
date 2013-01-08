From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Mon, 07 Jan 2013 19:11:27 -0800
Message-ID: <1357614687.12749.41.camel@joe-AO722>
References: <50E82D7D.4090107@asianux.com>
	 <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>
	 <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>
	 (sfid-20130107_055017_668200_9F1C3EAF) <1357544828.9912.0.camel@jlt4.sipsolutions.net>
	 <1357579362.21481.45.camel@joe-AO722> <50EB8B1A.9000404@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50EB8B1A.9000404-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-08 at 10:57 +0800, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8808=E6=97=A5 01:22, Joe Perches =E5=86=
=99=E9=81=93:
> > On Mon, 2013-01-07 at 08:47 +0100, Johannes Berg wrote:
> >> > print_ssid() is used in two or
> >> > three legacy drivers only, not in any modern driver, and is unli=
kely to
> >> > be used in the more modern drivers due to tracing etc.
> > Swell.  It was just another way to correct those overrun
> > errors Chen Gang found.
> >=20
>   sorry, I am not quite clear about what you said.

You found some overrun errors and proposed a patch.
Your solution could output incomplete SSIDs.

I proposed a different patch that would fully output
any binary/non-ascii printable SSID.

I also proposed a different mechanism to avoid the
overrun via printk and also avoid possibly excessive
stack consumption as a means for John Linville to
select 1 of the above options.

I don't care what is done with any of those proposed
patches.

Clear?

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

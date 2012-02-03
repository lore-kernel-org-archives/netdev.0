From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 03 Feb 2012 08:26:12 +0100
Message-ID: <1328253972.2480.42.camel@edumazet-laptop>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
	 <4F2A87B0.6070900@profihost.ag>
	 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120202.143957.2251106530056768980.davem@davemloft.net>
	 <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42203 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397Ab2BCH0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 02:26:16 -0500
In-Reply-To: <4F2B8348.3090305@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 07:48 +0100, Stefan Priebe - Pr=
ofihost AG
a =C3=A9crit :
> Am 03.02.2012 01:42, schrieb Greg KH:
> > On Thu, Feb 02, 2012 at 02:39:57PM -0500, David Miller wrote:
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Thu, 02 Feb 2012 16:04:15 +0100
> >>
> >>> David, what do you think ?
> >>
> >> I frankly don't care at this point.
> >>
> >> The only reasonable thing is if someone can successfully do the
> >> backport, but if that's not possible there really isn't anything
> >> reasonable we can do, all the other options have fatal negative
> >> consequences which make them completely untenable.
> >=20
> > I agree.  I'm pretty sure the distros basing their releases on 3.0 =
are
> > aware of this issue, so perhaps someone could dig through those tre=
e and
> > see how they resolved this issue, if at all.
> >=20
> I haven't found any distris which has backported something regarding
> this issue.
>=20
> Also it seems that there's only Ubuntu using 3.0. Debian and others h=
ave
> already moved to 3.1 / 3.2. Anything i miss?
>=20
> I've made my own backport of the patch and removed at least 1-2
> dependencies. Anybody interested?
>=20

If you did the work, post it for review.

Thanks

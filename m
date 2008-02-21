From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:01:19 -0800
Message-ID: <1203588079.20345.15.camel@brick>
References: <1203586467.20345.14.camel@brick>
	 <20080221.015743.222059206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:52816 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbYBUKBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:01:06 -0500
Received: by wx-out-0506.google.com with SMTP id h31so2514657wxd.4
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 02:01:03 -0800 (PST)
In-Reply-To: <20080221.015743.222059206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-21 at 01:57 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Thu, 21 Feb 2008 01:34:27 -0800
>=20
> > commit 0795af5729b18218767fab27c44b1384f72dc9ad
> > Author: Joe Perches <joe@perches.com>
> > Date:   Wed Oct 3 17:59:30 2007 -0700
> >=20
> >     [NET]: Introduce and use print_mac() and DECLARE_MAC_BUF()
> >    =20
> >     This is nicer than the MAC_FMT stuff.
> >    =20
> >     Signed-off-by: Joe Perches <joe@perches.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >=20
> > Introduced:
> > net/mac80211/debugfs_sta.c: In function =E2=80=98ieee80211_sta_debu=
gfs_add=E2=80=99:
> > net/mac80211/debugfs_sta.c:211: warning: statement with no effect
> >=20
> > Does print_mac modify the mac buffer in-place, or return a new buff=
er?
>=20
> It modifies the buffer in place.
>=20
> The warning is likely not from Joe's patch, but more likely
> from the __pure attribute I recently added to print_mac()'s
> declaration.  If so, we'll need to perhaps rework things.

In this case, it's being passed to a debugfs create function, could it
instead use sysfs_format_mac?

Harvey


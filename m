From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Small Bluetooth fix for 2.6.27-rc6
Date: Fri, 12 Sep 2008 04:59:10 +0200
Message-ID: <1221188350.6695.7.camel@californication>
References: <1221185492.6695.2.camel@californication>
	 <20080911.191234.248780619.davem@davemloft.net>
	 <1221185702.6695.4.camel@californication>
	 <20080911.195147.81650729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60807 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964AbYILC6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:58:39 -0400
In-Reply-To: <20080911.195147.81650729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > > > > > Please pull from
> > > > > >=20
> > > > > >     git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/=
bluetooth-2.6.git master
> > > > >=20
> > > > > You did your work against Linus's tree, so I can't pull this,
> > > > > it will bring in tons of irrelevant stuff into net-2.6.
> > > > >=20
> > > > > Please send me pull requests using net-2.6 as your base.
> > > >=20
> > > > I re-based the tree on net-2.6 now. Please pull.
> > >=20
> > > Pulled, thanks.
> >=20
> > I assume you want me to queue the compiler warning fix for the next
> > merge window, right?
>=20
> Which one?

the one for this warning:

  CC [M]  net/bluetooth/af_bluetooth.o
net/bluetooth/af_bluetooth.c:60: warning: =E2=80=98bt_key_strings=E2=80=
=99 defined but not used
net/bluetooth/af_bluetooth.c:71: warning: =E2=80=98bt_slock_key_strings=
=E2=80=99 defined but not used

It is not a new one, it just got ignored by everybody and now I got
annoyed enough to fix it. I just don't know what's that take on compile=
r
warning fixes after the merge window. Do we want them or not. I can
queue this up for 2.6.28.

Regards

Marcel



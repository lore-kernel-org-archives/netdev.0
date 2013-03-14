From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: atl1c issues on 3.8.2
Date: Thu, 14 Mar 2013 15:31:00 +0100
Message-ID: <1363271460.29475.14.camel@edumazet-glaptop>
References: <20130312161753.281681f2@milhouse>
	 <1363103144.13690.12.camel@edumazet-glaptop>
	 <20130312180942.4198e88e@milhouse>
	 <1363154258.13690.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:48192 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923Ab3CNObF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 10:31:05 -0400
Received: by mail-ee0-f45.google.com with SMTP id b57so1055245eek.18
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 07:31:03 -0700 (PDT)
In-Reply-To: <1363154258.13690.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-13 at 06:57 +0100, Eric Dumazet wrote:
> On Tue, 2013-03-12 at 18:09 +0100, Michael B=C3=BCsch wrote:
> > On Tue, 12 Mar 2013 16:45:44 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > On Tue, 2013-03-12 at 16:17 +0100, Michael B=C3=BCsch wrote:
> > > > Hi,
> > > >=20
> > > > Starting with 3.8.x scp stalls the atl1c based interface on my =
Asus Eeepc 1011px.
> > > > iperf (for example) does not do that. But after scp stalled the=
 interface,
> > > > iperf transfers fail, too.
> > >=20
> > > I am pretty sure David stable list contains the needed fix=20
> > >=20
> > > http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
> >=20
> > No this didn't fix it.
> >=20
> > However, I tried to revert 69b08f62e17439ee3d436faf0b9a7ca6fffb78db=
 again,
> > which already caused trouble for me in 3.7
> > and this fixed the issue.
> >=20
> > So it seems that this still is the same or a related issue that I r=
eported
> > for 3.7. I just wrongly stated that the problem was fixed in 3.8, b=
ecause my
> > simple ping test doesn't catch it on 3.8.
> >=20
>=20
>=20


And it seems the possible fix is here :

http://patchwork.ozlabs.org/patch/227666/

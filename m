From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Thu, 03 Jun 2010 05:54:00 +0200
Message-ID: <1275537240.29413.45.camel@edumazet-laptop>
References: <1275496439.2725.203.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021140320.30182@router.home>
	 <20100602.101258.134121018.davem@davemloft.net>
	 <20100602.103102.121237521.davem@davemloft.net>
	 <20100602235007.02506d99.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36742 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933805Ab0FCDyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 23:54:04 -0400
Received: by wyi11 with SMTP id 11so2460554wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 20:54:03 -0700 (PDT)
In-Reply-To: <20100602235007.02506d99.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 23:50 -0400, Bill Fink a =C3=A9crit :
> On Wed, 02 Jun 2010, David Miller wrote:
>=20
> > Just in case people are really so clueless as to be unable to figur=
e
> > this out:
> >=20
> > echo 1 >/sys/kernel/debug/tracing/events/skb/kfree_skb/enable
> > ...do some stuff...
> > cat /sys/kernel/debug/tracing/trace
> >=20
> > You can even trace it using 'perf' by passing "skb:kfree_skb"
> > as the event specifier.
>=20
> Could someone remind me where to get documentation for obtaining
> and using perf.
>=20

Its sources are included in kernel tree

cd tools/perf
make
=2E/perf --help



From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Thu, 07 Oct 2010 12:06:44 +0200
Message-ID: <1286446004.6992.7.camel@firesoul.comx.local>
References: <20101005141833.20929.10943.stgit@localhost>
	 <20101006.233611.68115178.davem@davemloft.net>
	 <1286433848.9417.49.camel@edumazet-laptop>
	 <20101006.234611.191419337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:44225 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab0JGKGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 06:06:48 -0400
In-Reply-To: <20101006.234611.191419337.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-06 at 23:46 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 07 Oct 2010 08:44:08 +0200
>=20
> > Le mercredi 06 octobre 2010 =C3=A0 23:36 -0700, David Miller a =C3=A9=
crit :
> >> From: Jesper Dangaard Brouer <hawk@comx.dk>
> >> Date: Tue, 05 Oct 2010 16:18:33 +0200
> >>=20
> >> > Network driver igb: Improve the accuracy of stats in /proc/net/d=
ev, by
> >> > updating the adapter stats when reading /proc/net/dev.  Currentl=
y the
> >> > stats are updated by the watchdog timer every 2 sec, or when get=
ting
> >> > stats via ethtool -S.
> >> >=20
> >> > A number of userspace apps read these /proc/net/dev stats every =
second,
> >> > e.g. ifstat, which then gives a perceived very bursty traffic pa=
ttern,
> >> > which is actually false.
> >> >=20
> >> > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> >>=20
> >> I assume that the Intel folks will take care of integrating this
> >> now that the locking is fixed.
> >=20
> > I integrated Jesper patch into my cumulative patch.
>=20
> Ok.

I'm fine with this, as long as the commit message describe this change
of accuracy of stats in /proc/net/dev.

Something like:

 This patch also increase the accuracy of stats in /proc/net/dev, by
 updating the adapter stats when reading /proc/net/dev.  Previously
 the stats were only updated by the watchdog timer every 2 sec, which
 resulted in false observations from userspace.


--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer



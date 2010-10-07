From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Thu, 07 Oct 2010 08:44:08 +0200
Message-ID: <1286433848.9417.49.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
	 <20101006.233611.68115178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@comx.dk, netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64496 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab0JGGoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:44:17 -0400
Received: by fxm4 with SMTP id 4so178341fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 23:44:16 -0700 (PDT)
In-Reply-To: <20101006.233611.68115178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 octobre 2010 =C3=A0 23:36 -0700, David Miller a =C3=A9cr=
it :
> From: Jesper Dangaard Brouer <hawk@comx.dk>
> Date: Tue, 05 Oct 2010 16:18:33 +0200
>=20
> > Network driver igb: Improve the accuracy of stats in /proc/net/dev,=
 by
> > updating the adapter stats when reading /proc/net/dev.  Currently t=
he
> > stats are updated by the watchdog timer every 2 sec, or when gettin=
g
> > stats via ethtool -S.
> >=20
> > A number of userspace apps read these /proc/net/dev stats every sec=
ond,
> > e.g. ifstat, which then gives a perceived very bursty traffic patte=
rn,
> > which is actually false.
> >=20
> > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>=20
> I assume that the Intel folks will take care of integrating this
> now that the locking is fixed.
>=20

I integrated Jesper patch into my cumulative patch.

BTW, ixgbe has similar locking problem.




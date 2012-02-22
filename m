From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Wed, 22 Feb 2012 08:21:33 +0100
Message-ID: <1329895293.18384.74.camel@edumazet-laptop>
References: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
	  <1329851004.18384.45.camel@edumazet-laptop>
	  <20120221.140716.1396286389544946379.davem@davemloft.net>
	  <1329851756.18384.47.camel@edumazet-laptop>
	 <1329857209.18384.53.camel@edumazet-laptop>
	 <alpine.SOC.1.00.1202220918220.21339@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35462 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab2BVHVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:21:39 -0500
Received: by werb13 with SMTP id b13so4288330wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 23:21:38 -0800 (PST)
In-Reply-To: <alpine.SOC.1.00.1202220918220.21339@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 f=C3=A9vrier 2012 =C3=A0 09:19 +0200, mroos@linux.ee a =C3=
=A9crit :
> > What about following patch ?
> >=20
> > Meelis, can you test it please ?
>=20
> Works fine, thank you!
> =20
> > [PATCH] atm: clip: remove clip_tbl
> >=20
> > Commit 32092ecf0644 (atm: clip: Use device neigh support on top of
> > "arp_tbl".) introduced a bug since clip_tbl is zeroed : Crash occur=
s in
> > __neigh_for_each_release()
> >=20
> > idle_timer_check() must use instead arp_tbl and neigh_check_cb() sh=
ould
> > ignore non clip neighbours.
> >=20
> > Idea from David Miller.
> >=20
> > Reported-by: Meelis Roos <mroos@linux.ee>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Tested-by: Meelis Roos <mroos@linux.ee>
>=20

Thanks !

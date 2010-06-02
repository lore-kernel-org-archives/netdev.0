From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add additional lock to qdisc to increase
 throughput
Date: Wed, 02 Jun 2010 16:52:50 +0200
Message-ID: <1275490370.2725.178.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1274454480.2439.418.camel@edumazet-laptop>
	 <80769D7B14936844A23C0C43D9FBCF0F256284B068@orsmsx501.amr.corp.intel.com>
	 <20100602.051019.180420492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59632 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab0FBOwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:52:55 -0400
Received: by wyi11 with SMTP id 11so1931708wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 07:52:54 -0700 (PDT)
In-Reply-To: <20100602.051019.180420492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 05:10 -0700, David Miller a =C3=A9crit =
:
> From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
> Date: Fri, 21 May 2010 13:04:20 -0700
>=20
> > Eric Dumazet wrote:
> >> Tests with following script gave a boost from ~50.000 pps to ~600.=
000
> >> pps on a dual quad core machine (E5450 @3.00GHz), tg3 driver.
> >> (A single netperf flow can reach ~800.000 pps on this platform)
> >>=20
> >> for j in `seq 0 3`; do
> >>   for i in `seq 0 7`; do
> >>     netperf -H 192.168.0.1 -t UDP_STREAM -l 60 -N -T $i -- -m 6 &
> >>   done
> >> done
> >=20
> > Running the same script with your patch my results went from 200Kpp=
s to 1.2Mpps on a dual Xeon 5570.
> >=20
> > Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> Applied, thanks guys.

Thanks David, I realize you did all the necessary changes after
qdisc_run_begin/qdisc_is_running/ integration ;)



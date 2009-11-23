From: robert@herjulf.net
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 19:30:46 +0100
Message-ID: <19210.54486.353397.804028@gargle.gargle.HOWL>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	<2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	<1258968980.2697.9.camel@ppwaskie-mobl2>
	<4B0A6218.9040303@gmail.com>
	<Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>
	<4B0A9E4E.9010804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atthis.its.uu.se ([130.238.7.58]:43489 "EHLO atthis.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbZKWQUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 11:20:45 -0500
In-Reply-To: <4B0A9E4E.9010804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > Jesper Dangaard Brouer a =E9crit :
 >=20
 > > How is your smp_affinity mask's set?
 > >=20
 > > grep . /proc/irq/*/fiber1-*/../smp_affinity
 >=20

 Weird... set clone_skb to 1 to be sure and vary dst or something so=20
 the HW classifier selects different queues and with proper RX affinty.=
=20
=20
 You should see in /proc/net/softnet_stat something like:

012a7bb9 00000000 000000ae 00000000 00000000 00000000 00000000 00000000=
 00000000
01288d4c 00000000 00000049 00000000 00000000 00000000 00000000 00000000=
 00000000
0128fe28 00000000 00000043 00000000 00000000 00000000 00000000 00000000=
 00000000
01295387 00000000 00000047 00000000 00000000 00000000 00000000 00000000=
 00000000
0129a722 00000000 0000004a 00000000 00000000 00000000 00000000 00000000=
 00000000
0128c5e4 00000000 00000046 00000000 00000000 00000000 00000000 00000000=
 00000000
0128f718 00000000 00000043 00000000 00000000 00000000 00000000 00000000=
 00000000
012993e3 00000000 0000004a 00000000 00000000 00000000 00000000 00000000=
 00000000

Or something is...
=20
Cheers

					--ro

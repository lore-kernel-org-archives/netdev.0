From: Marco Berizzi <pupilla@hotmail.com>
Subject: RE: rx_dropped packets stop with tcpdump running
Date: Fri, 20 Apr 2012 17:25:28 +0200
Message-ID: <DUB108-W57C2F8FCF145C20E3B8BF1B2220@phx.gbl>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>,<1334841865.2395.177.camel@edumazet-glaptop>,<1334842088.2395.178.camel@edumazet-glaptop>,<061C8A8601E8EE4CA8D8FD6990CEA8910FF2D23F@ORSMSX102.amr.corp.intel.com>
 <DUB108-W45246BF22ED8BAB93B78C8B2220@phx.gbl>,<4F9179E3.5020507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <tushar.n.dave@intel.com>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s30.dub0.hotmail.com ([157.55.2.105]:32880 "EHLO
	dub0-omc4-s30.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753824Ab2DTPZe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 11:25:34 -0400
In-Reply-To: <4F9179E3.5020507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


brian.haley@hp.com wrote:
> 0x886d or 0x86DD? That second one is IPv6, you might just need to loa=
d the module.

here is the tcpdump:

17:23:25.561398 00:19:99:90:ba:72 > ff:ff:ff:ff:ff:ff, ethertype Unknow=
n (0x886d), length 64:=20
=A0=A0=A0=A0=A0=A0=A0 0x0000:=A0 0001 0001 000c 24e2 0001 0019 9990 ba7=
2=A0 ......$........r
=A0=A0=A0=A0=A0=A0=A0 0x0010:=A0 0000 0500 2304 6364 726f 447b d700 80f=
8=A0 ....#.cdroD{....
=A0=A0=A0=A0=A0=A0=A0 0x0020:=A0 ffff 20d1 b631 80fa ffff e02b fb30 80f=
a=A0 .....1.....+.0..
=A0=A0=A0=A0=A0=A0=A0 0x0030:=A0 ffff=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 ..
17:23:25.561402 00:19:99:90:ba:73 > ff:ff:ff:ff:ff:ff, ethertype Unknow=
n (0x886d), length 64:=20
=A0=A0=A0=A0=A0=A0=A0 0x0000:=A0 0001 0001 000c 24e2 0002 0019 9990 ba7=
2=A0 ......$........r
=A0=A0=A0=A0=A0=A0=A0 0x0010:=A0 6700 5400 6800 7200 6500 7300 6800 6f0=
0=A0 g.T.h.r.e.s.h.o.
=A0=A0=A0=A0=A0=A0=A0 0x0020:=A0 6c00 6400 0000 3700 3200 0000 0000 000=
0=A0 l.d...7.2.......
=A0=A0=A0=A0=A0=A0=A0 0x0030:=A0 0000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 ..



 		 	   		  
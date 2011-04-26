From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 19:10:01 +0200
Message-ID: <1303837801.3358.65.camel@edumazet-laptop>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	 <1303730701.2747.110.camel@edumazet-laptop>
	 <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	 <1303745915.2747.151.camel@edumazet-laptop>
	 <BANLkTikcn832pXzxPjM032ZuRi8o0SQ++Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58776 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab1DZRKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 13:10:06 -0400
Received: by wwa36 with SMTP id 36so964691wwa.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 10:10:04 -0700 (PDT)
In-Reply-To: <BANLkTikcn832pXzxPjM032ZuRi8o0SQ++Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 18:58 +0200, Dominik Kaspar a =C3=A9crit =
:
> Hi Eric,
>=20
> On Mon, Apr 25, 2011 at 5:38 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > Since you have at sender a rule to spoof destination address of pac=
kets,
> > you should make sure you dont send "super packets (up to 64Kbytes)"=
,
> > because it would stress the multipath more than you wanted to. This=
 way,
> > you send only normal packets (1500 MTU).
> >
> > ethtool -K eth0 tso off
> > ethtool -K eth0 gso off
> >
> > I am pretty sure it should help your (atypic) workload.
>=20
> I made new experiments with the exact same multipath setup as before,
> but disabled TSO and GSO on all involved Ethernet interfaces. However=
,
> this did not seem to change much about TCP's behavior when packets ar=
e
> striped over heterogeneous paths. You can see the results of four
> 20-minute experiments on this plot:
>=20
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0.png
>=20
> Cheers,
> Dominik

Hi Dominik

Any chance to have a pcap file from sender side, of say first 10.000
packets ?




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 00:14:46 +0100
Message-ID: <1329174886.2523.16.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <1329173056.2523.14.camel@edumazet-laptop>
	 <CADVnQykiHqmjCSofbMVL13iZaPhuJwRDUqPoCw8f2ynzpfdQTA@mail.gmail.com>
	 <1486820.tZrzp7eZ2l@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55258 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891Ab2BMXOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 18:14:50 -0500
Received: by wgbdt10 with SMTP id dt10so5342818wgb.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:14:49 -0800 (PST)
In-Reply-To: <1486820.tZrzp7eZ2l@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 01:09 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :
> =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA =
13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 17:51:20 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > Hi,
> >=20
> > Could you also please post a tcpdump of a "good" transfer on a 3.1.=
x
> > kernel to the same server? It would be nice to make sure the option=
s
> > and advertised windows are the same in both cases.
> >=20
> > neal
>=20
> Hi,
>=20
> Here tcpdump for 3.1.10 kernel (2.6.41.10-3.fc15.i686):
>=20
> tcpdump: verbose output suppressed, use -v or -vv for full protocol d=
ecode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 by=
tes
> 01:03:59.499533 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.],=
 seq 1015030570:1015032018, ack 3902015221, win 46, options [nop,nop,TS=
 val 3724352664 ecr 4211303], length 1448
> 01:03:59.499655 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.],=
 seq 1448:2896, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211303], length 1448
> 01:03:59.499665 IP AA.BB.CC.XY.50925 > 213.83.42.56.60216: Flags [.],=
 ack 2896, win 41449, options [nop,nop,TS val 4211360 ecr 3724352664], =
length 0
> 01:03:59.499778 IP 213.83.42.56.60216 > AA.BB.CC.XY.50925: Flags [.],=
 seq 2896:4344, ack 1, win 46, options [nop,nop,TS val 3724352664 ecr 4=
211303], length 1448

Hmm, we miss the first messages (SYN & SYNACK) to check what was
negociated.

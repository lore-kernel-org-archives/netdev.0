From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 16:09:59 +0200
Message-ID: <2181120.DTPSTq3Adr@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <2578783.aLeNzacy8Q@localhost.localdomain> <1329198902.24837.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63898 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616Ab2BNOKU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 09:10:20 -0500
Received: by bkcjm19 with SMTP id jm19so5480022bkc.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 06:10:19 -0800 (PST)
In-Reply-To: <1329198902.24837.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 01:49 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> =C3=A9crit :
> > =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=
=D1=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA=
 13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 23:44:16 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > > Le lundi 13 f=C3=A9vrier 2012 =C3=A0 21:18 +0100, Eric Dumazet a =
=C3=A9crit :
> > > I wonder if the other side of your link believes link is in half =
duplex
> > > mode... Could you please check ?
> >=20
> > I have no access to other side, the only I can check is ethtool and=
 mii-diag (kernel-3.2.3):
> I have seen numerous duplex mismatches in some data centers after a
> reboot. One side believes link is full duplex, the other side believe=
s
> its half duplex.
>=20

Was no such problems here.

> You could setup a pktgen/hping3 to send 2.000 small frames per second=
 to
> your gateway and check if you still can download at normal speeds.
>=20
> hping3 --udp -s 9 -p 9 -i u500 192.168.1.1

Download speed not changed when running this command for my gw.

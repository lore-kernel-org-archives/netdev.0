From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 06:55:02 +0100
Message-ID: <1329198902.24837.11.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <3490386.xy2kafBK9b@localhost.localdomain>
	 <1329173056.2523.14.camel@edumazet-laptop>
	 <2578783.aLeNzacy8Q@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:32976 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab2BNFzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 00:55:07 -0500
Received: by werb13 with SMTP id b13so3933386wer.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 21:55:05 -0800 (PST)
In-Reply-To: <2578783.aLeNzacy8Q@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 01:49 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :
> =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA =
13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 23:44:16 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > Le lundi 13 f=C3=A9vrier 2012 =C3=A0 21:18 +0100, Eric Dumazet a =C3=
=A9crit :
> > I wonder if the other side of your link believes link is in half du=
plex
> > mode... Could you please check ?
>=20
> I have no access to other side, the only I can check is ethtool and m=
ii-diag (kernel-3.2.3):

I have seen numerous duplex mismatches in some data centers after a
reboot. One side believes link is full duplex, the other side believes
its half duplex.

You could setup a pktgen/hping3 to send 2.000 small frames per second t=
o
your gateway and check if you still can download at normal speeds.

hping3 --udp -s 9 -p 9 -i u500 192.168.1.1

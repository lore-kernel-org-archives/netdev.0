From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.39.2 BUG: unable to handle kernel NULL pointer dereference
Date: Sun, 26 Jun 2011 05:57:34 -0700 (PDT)
Message-ID: <20110626.055734.167122034165875195.davem@davemloft.net>
References: <1309082172.2532.31.camel@edumazet-laptop>
	<BANLkTikhGVYAFEZGS-AZf3CyS4yVN+Acvg@mail.gmail.com>
	<1309092147.2532.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.coatti@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab1FZM5k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 08:57:40 -0400
In-Reply-To: <1309092147.2532.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 26 Jun 2011 14:42:27 +0200

> Le dimanche 26 juin 2011 =E0 13:34 +0200, Fabio Coatti a =E9crit :
>> 2011/6/26 Eric Dumazet <eric.dumazet@gmail.com>:
>> > Le dimanche 26 juin 2011 =E0 10:28 +0200, Fabio Coatti a =E9crit :
>> >> I'm trying to boot with 2.6.39.2 but the process stops somewhere =
in
>> >> network stack, with a BUG: report.
>> >> I've been able to capture the kernel messages usign netconsole, s=
o be
>> >> patient with poor alignment :)
>>=20
>> >
>> > Hi Fabio
>> >
>> > Could you test following patch :
>> >
>> > http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommitdiff;h=3D6407d74c5106bb362b4087693688afd34942b094
>> >
>> >
>> > This should be included in 2.6.39.3, if you confirm this fixes the
>> > problem.
>> >
>>=20
>> Yes, I can confirm that your patch fixes the problem, now running
>> 2.6.39.2 just fine. Many thanks!
>=20
> Thanks for testing, David will include this to his stable queue I
> presume.

Yep, I will.

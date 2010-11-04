From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Routing over multiple interfaces
Date: Thu, 04 Nov 2010 15:01:27 +0100
Message-ID: <1288879287.2659.84.camel@edumazet-laptop>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <4CD08C6D.1090107@arndnet.de>  <1288875102.4357.40.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40328 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab0KDOBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 10:01:37 -0400
Received: by wyf28 with SMTP id 28so2016876wyf.19
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 07:01:36 -0700 (PDT)
In-Reply-To: <1288875102.4357.40.camel@lat1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 04 novembre 2010 =C3=A0 13:51 +0100, Patrick Schaaf a =C3=A9cr=
it :
> > iptables -t mangle -A PREROUTING -d $EXTERNAL -m statistic --mode n=
th --every 2 -j MARK --set-mark 6
>=20
> If statistics match is missing, a pretty good alternative I recently
> "found" is using u32 to match for a bit from the IP ID. That is a
> stateless decision, and here it probably has the theoretical advantag=
e
> of putting all fragments of a given packet onto the same link.
>=20
> iptables -t mangle -A PREROUTING ... -m u32 --u32 0x2&0x1=3D0x0 -j MA=
RK
> --set-mark 6

Sure, thats a good tip/idea, but note many UDP frames have IP.id =3D 0




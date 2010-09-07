From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 23:39:04 +0200
Message-ID: <1283895544.2634.256.camel@edumazet-laptop>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>
	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>
	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl>
	 <1283877391.2313.62.camel@edumazet-laptop>
	 <1283887569.2634.95.camel@edumazet-laptop>  <4C86AE96.40704@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49614 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab0IGVjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:39:09 -0400
Received: by fxm16 with SMTP id 16so330973fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 14:39:08 -0700 (PDT)
In-Reply-To: <4C86AE96.40704@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 23:28 +0200, Krzysztof Ol=C4=99dzki a=
 =C3=A9crit :

> With the above patch I'm no longer able to reproduce the problem. Tha=
nks!
>=20
> Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>
>=20

Thanks a lot !

> BTW: why it takes so long to trigger this bug and it is only possible=
=20
> over a loopback interface?

Its a bit tricky : You need at least 10 sockets linked in a particular
hash chain.

To check this, you can :

cat /proc/net/udp

maybe you have many sockets on port 123 or 53 ?

And about loopback, I have no idea... I am pretty sure I can trigger th=
e
bug with other interfaces.




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Thu, 27 Oct 2011 18:08:52 +0200
Message-ID: <1319731732.2601.40.camel@edumazet-laptop>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>
	 <1319716772.2601.26.camel@edumazet-laptop>
	 <CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Karel Rericha <karel@maxtel.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:51566 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab1J0QJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 12:09:03 -0400
Received: by gyb13 with SMTP id 13so2776334gyb.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 09:09:01 -0700 (PDT)
In-Reply-To: <CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 octobre 2011 =C3=A0 14:46 +0200, Karel Rericha a =C3=A9crit=
 :

> Actually I am doing some reseach to replace our main shaping machine
> with 60 000+ htb classes, which now saturates 12 core Xeon Westmere t=
o
> 30% (there are five gigabit network ports on each interface affinited
> to cores). AFAIK QFQ should be O(1) complexity so it would bring
> saturation a requirements for number of cores down considerably (HTB
> has O(log(N)) complexity).
>=20
> I have test machine and about two months to decide if we will stay
> with HTB or we will try something else. So it would be VERY helpful,
> if you would search you memory instead your dead disk :-) and send me
> some example of QFQ usage, if I can ask for a little of your time. I
> promise to have results published here in return.
>=20
> Thanks, Karel
>=20

That seems a good challenge to me ;)

=46irst upgrade to a recent kernel with QFQ included.
Also upgrade iproute2 to a recent enough version as well.

Then you discover "tc  ... qfq help" is not that helpful :(

# tc qdisc add dev eth3 root qfq help
Usage: ... qfq

OK, its parameters are :

	qfq weight num1 [maxpkt BYTES]

You should not touch maxpkt, its default value being 2048

Oh well, I just tried the obvious and my (remote) machine doesnt answer
to me anymore...

Time for a bit of debugging I am afraid :(

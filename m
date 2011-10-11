From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 16:56:23 +0400
Message-ID: <4E943CF7.6030905@msgid.tls.msk.ru>
References: <4E90212D.8030009@msgid.tls.msk.ru>		<1318091046.5276.22.camel@edumazet-laptop>	<4E9097C0.2030307@gmail.com>		<20111010101954.GB2840382@jupiter.n2.diac24.net>		<4E9307CB.4050704@msgid.tls.msk.ru>		<1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		<20111010151343.GB3260852@jupiter.n2.diac24.net>		<4E932278.8010802@tls.msk.ru>	<4E941198.9000307@msgid.tls.msk.ru>	 <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>	 <4E942F8A.90205@msgid.tls.msk.ru> <1318334674.2538.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:38245 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888Ab1JKM4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 08:56:24 -0400
In-Reply-To: <1318334674.2538.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

11.10.2011 16:04, Eric Dumazet wrote:
> Le mardi 11 octobre 2011 =C3=A0 15:59 +0400, Michael Tokarev a =C3=A9=
crit :
[]
>> (and it works).  With -s 1469, no ICMP packets can be seen
>> on e100 side.
>>
>> So it still may be the hardware... :)
>
> Yes, my patch was not needed, I was not sure sizeof(struct rfd) was
> included or not in the rfd.size setting (apparently its not needed)

Ok, good to know!

> Any counters increase in "ethtool -S eth0" ?

None at all.  Number of interrupts gets increased by 2 about every
2 seconds, even when the other side is doing ping -f, or not pinging
at all.

So it looks like the card merely ignores these packets.

So little result for so much efforts... :(

But it is not really that bad I think - it is an obsolete hardware.

Thank you for all the help!

/mjt

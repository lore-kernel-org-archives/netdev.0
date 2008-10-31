From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 12:10:10 +0100
Message-ID: <490AE792.60200@cosmosbay.com>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi> <20081031.005219.141937694.davem@davemloft.net> <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi> <20081031.025159.51432990.davem@davemloft.net> <490AE1CD.9040207@cosmosbay.com> <Pine.LNX.4.64.0810311300130.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	Andrew Morton <akpm@linux-foundation.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:49028 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbYJaLLI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 07:11:08 -0400
In-Reply-To: <Pine.LNX.4.64.0810311300130.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen a =E9crit :
> On Fri, 31 Oct 2008, Eric Dumazet wrote:
>=20
>> David Miller a =E9crit :
>> > From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
>> > Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)
>> > > > Let me remind that it is just a single process, so no ping-pon=
g=20
>> & other
>> > > lock related cache effects should play any significant role here=
,=20
>> no? (I'm
>> > > no expert though :-)).
>> > > Not locks or ping-pongs perhaps, I guess.  So it just sends and
>> > receives over a socket, implementing both ends of the communicatio=
n
>> > in the same process?
>> > > If hash chain conflicts do happen for those 2 sockets, just=20
>> traversing
>> > the chain 2 entries deep could show up.
>>
>> tbench is very sensible to cache line ping-pongs (on SMP machines of=
=20
>> course)
>=20
> ...Sorry to disappoint you but we were discussion there on my AIM9=20
> tcp_test results :-).
>=20

Well, before you added AIM9 on this topic, we were focusing on tbench :=
)

Sorry to disappoint you :)


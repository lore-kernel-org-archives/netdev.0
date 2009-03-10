From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Tue, 10 Mar 2009 06:19:27 +0100
Message-ID: <49B5F85F.1080508@cosmosbay.com>
References: <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>	 <20090309195906.M50328@bts.sk>	 <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>	 <20090309.165205.11054081.davem@davemloft.net> <1e41a3230903091709i740d95ddhefc1df2c71ea60b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, md@bts.sk,
	netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53061 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbZCJFTg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 01:19:36 -0400
In-Reply-To: <1e41a3230903091709i740d95ddhefc1df2c71ea60b6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heffner a =E9crit :
> On Mon, Mar 9, 2009 at 4:52 PM, David Miller <davem@davemloft.net> wr=
ote:
>> From: John Heffner <johnwheffner@gmail.com>
>> Date: Mon, 9 Mar 2009 13:23:15 -0700
>>
>>> A drop-tail queue size of 1000 packets on a local interface is
>>> questionable, and I think this is the real source of your problem.
>> Are you suggested we decrease it? :-)
>=20
> I am not so bold. :-D  (And note the drop-tail prefix.)
>=20
> A long queue with AQM would probably be best, but would require
> careful testing before enabling by default.  It would almost certainl=
y
> cause pain for some.
>=20
> And, for the vast majority of people for whom the local interface is
> not the bottleneck, it makes no difference.  It hurts worst for
> someone doing bulk transfer with a GigE device in 100 Mbps (or worse,
> 10-Mbps) mode, where 1000 pkts is a long time, while simultaneously
> doing something latency-sensitive.  I suspect this is the case Marian
> is experiencing.
>=20

Interesting stuff indeed.

Could you tell us more about AQM ?




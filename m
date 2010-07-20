From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Very low latency TCP for clusters
Date: Tue, 20 Jul 2010 10:24:55 -0700
Message-ID: <4C45DBE7.8070401@hp.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>	<1279561319.2553.153.camel@edumazet-laptop>	<AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>	<1279576980.2458.56.camel@edumazet-laptop>	<AANLkTillCVWMHHBImGEeRYy2MJYqtGIvSPvacLKJnpP2@mail.gmail.com> <1279603570.2458.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:15037 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab0GTRY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 13:24:57 -0400
In-Reply-To: <1279603570.2458.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le lundi 19 juillet 2010 =E0 16:37 -0700, Tom Herbert a =E9crit :
>=20
>>That's pretty pokey ;-) I see numbers around 25 usecs between to
>>machines, this is with TCP_NBRR.  With TCP_RR it's more like 35 usecs=
,
>>so eliminating the scheduler is already a big reduction.  That leaves
>>18 usecs in device time, interrupt processing, network, and cache
>>misses; 7 usecs in TCP processing, user space.  While 5 usecs is an
>>aggressive goal, I am not ready to concede that there's an
>>architectural limit in either NICs, TCP, or sockets that can't be
>>overcome.
>=20
> Last time I tried TCP_NBRR, it was not working (not even compiled in)=
, I
> guess I should submit a bug report to Rick ;)

Indeed!-)  Actually, my first thought upon reading what Tom wrote was "=
Wow, I'm=20
amazed it still works" :)  That code probably hasn't been visited much =
since the=20
heydays of T/TCP (transactional).

Getting it compiled-in probably required a hand-editing of the config.h=
 file=20
after the ./configure.  Patches to add a --enable-nbrr would be graciou=
sly accepted.

happy benchmarking,

rick jones

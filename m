From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 22:41:43 +0200
Message-ID: <49D12E87.4090005@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com> <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com> <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com> <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk> <49D12387.20507@cosmosbay.com> <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41810 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758681AbZC3Ulu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 16:41:50 -0400
In-Reply-To: <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =E9crit :
> On Mon, 30 Mar 2009, Eric Dumazet wrote:
>=20
>> Jesper Dangaard Brouer a =E9crit :
>>>
>>>> Eric Dumazet wrote:
>>>>>  "tbench 8" results on my 8 core machine (32bit kernel, with
>>>>>  conntracking on) : 2319 MB/s instead of 2284 MB/s
>>>
>>> How do you achieve this impressing numbers?
>>> Is it against localhost? (10Gbit/s is max 1250 MB/s)
>>>
>>
>> tbench is a tcp test on localhost yes :)
>=20
> I see!
>=20
> Using a Sun 10GbE NIC I was only getting a throughput of 556.86 MB/se=
c
> with 64 procs (between an AMD Phenom X4 and a Core i7).  (Not tuned
> multi queues yet ...)
>=20
> Against localhost I'm getting (not with applied patch):
>=20
>  1336.42 MB/sec on my AMD phenom X4 9950 Quad-Core Processor
>=20
>  1552.81 MB/sec on my Core i7 920 (4 physical cores, plus 4 threads)

Strange results, compared to my E5420 (I thought i7 was faster ??)

>=20
>  2274.53 MB/sec on my dual CPU Xeon E5420 (8 cores)

Yes, my dev machine is a dual E5420 (8 cores) at 3.00 GHz
gcc version here is 4.3.3

>=20
>=20
>> Good to test tcp stack without going to NIC hardware
>=20
> Yes true, but this also stresses the process scheduler, I'm seeing
> around 800.000 context switches per sec on the Dual CPU Xeon system.
>=20

Indeed, tbench is a mix of tcp and process scheduler test/bench




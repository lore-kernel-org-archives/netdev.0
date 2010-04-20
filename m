From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Tue, 20 Apr 2010 15:13:15 +0200
Message-ID: <1271769195.7895.4.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271764941.3735.94.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42615 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0DTNN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 09:13:28 -0400
Received: by bwz19 with SMTP id 19so6922bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 06:13:26 -0700 (PDT)
In-Reply-To: <1271764941.3735.94.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 08:02 -0400, jamal a =C3=A9crit :=20
> folks,
>=20
> Thanks to everybody (Eric stands out) for your patience.=20
> I ended mostly validating whats already been said. I have a lot of da=
ta
> and can describe in details how i tested etc but it would require
> patience in reading, so i will spare you;-> If you are interested let=
 me
> know and i will be happy to share.
>=20
> Summary is:=20
> -rps good, gives higher throughput for apps
> -rps not so good, latency worse but gets better with higher input rat=
e
> or increasing number of flows (which translates to higher pps)
> -rps works well with newer hardware that has better cache structures.
> [Gives great results on my test machine a Nehalem single processor, 4
> cores each with two SMT threads that has a shared L2 between threads =
and
> a shared L3 between cores].=20
> Your selection of what the demux cpu is and where the target cpus are=
 is
> an influencing factor in the latency results. If you have a system wi=
th
> multiple sockets, you should get better numbers if you stay within th=
e
> same socket relative to going across sockets.
> -rps does a better job at helping schedule apps on same cpu thus
> localizing the app. The throughput results with rps are very consiste=
nt
> and better whereas in non-rps case, variance is _high_.
>=20
> My next step is to do some forwarding tests - probably next week. I a=
m
> concerned here because i expect the cache misses to be higher than th=
e
> app scenario (netdev structure and attributes could be touched by man=
y
> cpus)
>=20

Hi Jamal

I think your tests are very interesting, maybe could you publish them
somehow ? (I forgot to thank you about the previous report and nice
graph)

perf reports would be good too to help to spot hot points.




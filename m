From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH iputils ping]: report outstanding packets before sending
 next packet
Date: Tue, 10 Jan 2012 00:20:43 +0900
Message-ID: <4F0B05CB.1080803@linux-ipv6.org>
References: <201201050904.KAA04877@shell02.nsc.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: =?UTF-8?B?T2xlIEJq77+9cm4gSGVzc2Vu?= <obh@telenor.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46188 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755260Ab2AIPUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 10:20:46 -0500
In-Reply-To: <201201050904.KAA04877@shell02.nsc.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ole Bj=EF=BF=BDrn Hessen wrote:
> Hello,
>
> please accept following patch to ping to let ping report outstanding
> packets before sending next packet. This is a sorely missed feature
> from the old sun ping. Very useful together with the -D option:
>
>       ping -DO 10.122.145.180>  file
>       # wait next day
>       ^C
>       grep "no answer yet" file
>
>       [1325752664.026900] 64 bytes from 10.122.145.180: icmp_req=3D20=
 ttl=3D64 time=3D0.695 ms
>       [1325752665.026926] 64 bytes from 10.122.145.180: icmp_req=3D21=
 ttl=3D64 time=3D0.695 ms
>       [1325752666.026917] 64 bytes from 10.122.145.180: icmp_req=3D22=
 ttl=3D64 time=3D0.682 ms
>       [1325752667.026922] 64 bytes from 10.122.145.180: icmp_req=3D23=
 ttl=3D64 time=3D0.695 ms
>       [1325752669.026217] no answer yet for icmp_seq=3D24
>       [1325752670.026207] no answer yet for icmp_seq=3D25
>       ...
>       [1325752697.026206] no answer yet for icmp_seq=3D52
>       [1325752698.026205] no answer yet for icmp_seq=3D53
>       [1325752698.026962] 64 bytes from 10.122.145.180: icmp_req=3D54=
 ttl=3D64 time=3D0.717 ms
>       [1325752699.026930] 64 bytes from 10.122.145.180: icmp_req=3D55=
 ttl=3D64 time=3D0.690 ms
>       [1325752700.026928] 64 bytes from 10.122.145.180: icmp_req=3D56=
 ttl=3D64 time=3D0.695 ms
>
> Kind regards,
>
> Ole Bj=C3=B8rn Hessen,
> Telenor

Applied, thanks.

Please provide the "signed-off-by" line, next time.

--yoshfuji

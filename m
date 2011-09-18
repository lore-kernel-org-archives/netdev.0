From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Sun, 18 Sep 2011 14:04:44 -0700
Message-ID: <CAA93jw4sQJ63t6tH=SfUPahgprk1Yz4-E3yoMc6yvw=NeN1YBA@mail.gmail.com>
References: <4E696FD0.7060702@intel.com>
	<20110909015429.GA9156@gondor.apana.org.au>
	<4E6975B2.8000603@intel.com>
	<alpine.DEB.2.00.1109091050550.11963@melkinpaasi.cs.helsinki.fi>
	<CAA93jw7L9KyXVevZ8dqE+ExLYP9=CLMmj1gPD88ihBuC6ZovOQ@mail.gmail.com>
	<1316378349.31335.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61372 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932366Ab1IRVEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 17:04:45 -0400
Received: by iaqq3 with SMTP id q3so4557886iaq.19
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 14:04:44 -0700 (PDT)
In-Reply-To: <1316378349.31335.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2011 at 1:39 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le samedi 17 septembre 2011 =E0 11:30 -0700, Dave Taht a =E9crit :
>
>>
>> As cerowrt is one of the few projects enabling sack/dsack/ecn by
>> default, it would be good to know either
>>
>
> dsack is enabled by default on linux, not only cerowt project.
>
>> A) how to test to see if this problem is really a problem
>> B) should we apply the obvious fix
>
> Isnt Cerowrt a router, most of frames are forwarded anyway ?

A very large suite of network test tools runs on the router itself -
netperf, nuttcp, iperf, httping, etc.

netperf, for example, ships, enabled.

This is a means of being able to analyze performance of both the LFN
and wireless from a central point,
from a well defined platform,
without having a random desktop involved.

> This bug is relevant to linux hosts, receiving Duplicate Sacks (RFC
> 2883).
>
>
>
>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://the-edge.blogspot.com

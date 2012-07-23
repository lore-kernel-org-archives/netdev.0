From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Mon, 23 Jul 2012 19:54:54 +0200
Message-ID: <500D8FEE.7050802@itcare.pl>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>  <20120722.173951.1794347789063177131.davem@davemloft.net> <1343027752.2626.10175.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8.iq.pl ([86.111.242.217]:54375 "EHLO smtp8.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754533Ab2GWSC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 14:02:59 -0400
In-Reply-To: <1343027752.2626.10175.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2012-07-23 09:15, Eric Dumazet pisze:
> On Sun, 2012-07-22 at 17:39 -0700, David Miller wrote:
>> Just FYI, I'm pushing this work out to net-next now.
>> --
> Excellent !
>
> Thanks a lot David
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Yes
Excellent work.

I make some real life tests with 10Gbit traffic and make some rdos.
With kernel 3.4.5 when I reach 6M routing cache entries - traffic is no=
t=20
forwarded - on my hardware with 64G RAM

With kernel - 3.5.0-rc7-next-20120720 + David M. patches - route cache=20
removal + fix
Traffic is forwarder all the time at speed 8.2Mpps RX from traffic=20
generator and 8.2Mpps TX to the sink

Also I see performance improvement.

With kernel 3.4.5 I can reach maximum od 7.5Mpps with my hardware
And with kernel 3.5.0-rc7-next-20120720 i can reach 8.2Mpps - forwardin=
g=20
UDP performance - can be more - but my TX pktgen that use 6 cores can't=
=20
do more.

Really thanks for this :)


BR
Pawe=C5=82 Staszewski

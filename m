From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Mon, 14 Nov 2011 14:21:17 -0500 (EST)
Message-ID: <20111114.142117.1578594312371186159.davem@davemloft.net>
References: <20111114.000811.780218767629149648.davem@davemloft.net>
	<1321251945.17837.55.camel@edumazet-laptop>
	<1321286265.2272.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, bhutchings@solarflare.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org, tgraf@infradead.org,
	therbert@google.com, hadi@mojatatu.com, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1KNTWk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:22:40 -0500
In-Reply-To: <1321286265.2272.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Nov 2011 16:57:45 +0100

> Le lundi 14 novembre 2011 =E0 07:25 +0100, Eric Dumazet a =E9crit :
>> Le lundi 14 novembre 2011 =E0 00:08 -0500, David Miller a =E9crit :
>>=20
>> > I fully support bringing this thing back to life :-)
>>=20
>> I'll make extensive tests today and provide two patches when ready, =
with
>> all performance results.
>>=20
>> Some prefetch() calls will be removed, since build_skb() provides
>> already cache hot skb.
>=20
> Impressive results :
>=20
> before : 720.000 pps
> after :  820.000 pps
>=20
> [ One mono threaded application receiving UDP messages on a single
> socket, asking IP_PKTINFO ancillary info ]

Sweeeeeet.

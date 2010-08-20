From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] net: rps: skip fragment when computing rxhash
Date: Thu, 19 Aug 2010 17:11:16 -0700 (PDT)
Message-ID: <20100819.171116.233682060.davem@davemloft.net>
References: <1282107698-3456-1-git-send-email-xiaosuo@gmail.com>
	<1282112701.2456.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758Ab0HTAK7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 20:10:59 -0400
In-Reply-To: <1282112701.2456.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Aug 2010 08:25:01 +0200

> Le mercredi 18 ao=FBt 2010 =E0 13:01 +0800, Changli Gao a =E9crit :
>> Fragmented IP packets may have no transfer header, so when computing
>> rxhash, we should skip them.
>>=20
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

> BTW, it is nicer to add some spaces :
>=20
> 	if (ip->frag_off & htons(IP_MF | IP_OFFSET))

I took care of this.


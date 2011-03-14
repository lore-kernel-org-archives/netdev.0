From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pktgen: bug fix in transmission headers
 with frags=0
Date: Mon, 14 Mar 2011 13:47:51 -0700 (PDT)
Message-ID: <20110314.134751.104044608.davem@davemloft.net>
References: <1300112338.3423.27.camel@edumazet-laptop>
	<4D7E26A4.2070802@gmail.com>
	<1300113350.3423.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: daniel.turull@gmail.com, netdev@vger.kernel.org,
	robert@herjulf.net, jens.laas@its.uu.se, voravit@kth.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756413Ab1CNUrO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 16:47:14 -0400
In-Reply-To: <1300113350.3423.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Mar 2011 15:35:50 +0100

> Le lundi 14 mars 2011 =E0 15:31 +0100, Daniel Turull a =E9crit :
>> (bug introduced by commit 26ad787962ef84677a48c560
>> (pktgen: speedup fragmented skbs)
>>=20
>> The headers of pktgen were incorrectly added in a pktgen packet
>> without frags (frags=3D0). There was an offset in the pktgen headers=
=2E
>>=20
>> The cause was in reusing the pgh variable as a return variable in sk=
b_put
>> when adding the payload to the skb.
>>=20
>> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

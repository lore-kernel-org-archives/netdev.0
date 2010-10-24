From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel dont update the mtu on the route.
Date: Sun, 24 Oct 2010 15:24:48 -0700 (PDT)
Message-ID: <20101024.152448.246523906.davem@davemloft.net>
References: <1287496247-24127-1-git-send-email-Anders.Franzen@ericsson.com>
	<1287498728.2676.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anders.Franzen@ericsson.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933116Ab0JXWYZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 18:24:25 -0400
In-Reply-To: <1287498728.2676.110.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Oct 2010 16:32:08 +0200

> Le mardi 19 octobre 2010 =E0 15:50 +0200, Anders.Franzen@ericsson.com=
 a
> =E9crit :
>> From: Anders Franzen <anders.franzen@ericsson.com>
>>=20
>> The ip6_tunnel device did not unset the flag,
>> IFF_XMIT_DST_RELEASE. This will make the dev layer
>> to release the dst before calling the tunnel.
>> The tunnel will not update any mtu/pmtu info, since
>> it does not have a dst on the skb.
=2E..
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

Anders, please provide a proper "Signed-off-by: " tag in your
commit messages in the future.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: fix regression: do not release skb->dst before
 xmit
Date: Sat, 11 Jul 2009 20:31:02 -0700 (PDT)
Message-ID: <20090711.203102.250710958.davem@davemloft.net>
References: <1247317289-27867-1-git-send-email-contact@saschahlusiak.de>
	<4A58927F.7040405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: contact@saschahlusiak.de, netdev@vger.kernel.org,
	berni@birkenwald.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41544
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbZGLDa7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jul 2009 23:30:59 -0400
In-Reply-To: <4A58927F.7040405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 11 Jul 2009 15:24:15 +0200

> Sascha Hlusiak a =E9crit :
>> The sit module makes use of skb->dst in it's xmit function,
>> so since 93f154b594fe47 sit tunnels are broken, because the
>> flag IFF_XMIT_DST_RELEASE is not unset.
>>=20
>> This patch unsets that flag for sit devices to fix this
>> regression.
>>=20
>> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 V2] net: reorder struct sock fields
Date: Tue, 16 Nov 2010 11:35:39 -0800 (PST)
Message-ID: <20101116.113539.70186269.davem@davemloft.net>
References: <1289891544.3364.193.camel@edumazet-laptop>
	<1289922964.5372.443.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753528Ab0KPTfP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 14:35:15 -0500
In-Reply-To: <1289922964.5372.443.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Nov 2010 16:56:04 +0100

> Le mardi 16 novembre 2010 =E0 08:12 +0100, Eric Dumazet a =E9crit :
>> Right now, fields in struct sock are not optimally ordered, because =
each
>> path (RX softirq, TX completion, RX user,  TX user) has to touch fie=
lds
>> that are contained in many different cache lines.
>>=20
>=20
> Performance testing pointed out I forgot :
>=20
> - sk_drops, read for each queued packet, and incremented on packet dr=
ops
> - sk_flags tested in sock_def_readable()
> - sk_policy[0]
>=20
> Here is V2 of patch :
>=20
> [PATCH net-next-2.6 V2] net: reorder struct sock fields

Applied, thanks!

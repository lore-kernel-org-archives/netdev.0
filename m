From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net offloading: Do not mask out NETIF_F_HW_VLAN_TX for
 vlan.
Date: Tue, 18 Jan 2011 16:15:34 -0800 (PST)
Message-ID: <20110118.161534.232762549.davem@davemloft.net>
References: <1295333160-1667-1-git-send-email-jesse@nicira.com>
	<1295333714.3362.561.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752255Ab1ASAPA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 19:15:00 -0500
In-Reply-To: <1295333714.3362.561.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Jan 2011 07:55:14 +0100

> Le lundi 17 janvier 2011 =E0 22:46 -0800, Jesse Gross a =E9crit :
>> In netif_skb_features() we return only the features that are valid f=
or vlans
>> if we have a vlan packet.  However, we should not mask out NETIF_F_H=
W_VLAN_TX
>> since it enables transmission of vlan tags and is obviously valid.
>>=20
>> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>=20
> Thanks Jesse
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

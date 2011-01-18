From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net offloading: Do not mask out NETIF_F_HW_VLAN_TX for
 vlan.
Date: Tue, 18 Jan 2011 07:55:14 +0100
Message-ID: <1295333714.3362.561.camel@edumazet-laptop>
References: <1295333160-1667-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52600 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab1ARGzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 01:55:20 -0500
Received: by wyb28 with SMTP id 28so5795714wyb.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 22:55:19 -0800 (PST)
In-Reply-To: <1295333160-1667-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 22:46 -0800, Jesse Gross a =C3=A9crit :
> In netif_skb_features() we return only the features that are valid fo=
r vlans
> if we have a vlan packet.  However, we should not mask out NETIF_F_HW=
_VLAN_TX
> since it enables transmission of vlan tags and is obviously valid.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Thanks Jesse

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Now back to the "ethtool -K eth0 txvlan off" problem on bnx2

Is it a driver/software problem or hardware/firmware one ?




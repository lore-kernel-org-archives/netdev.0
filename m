From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] macvlan : fix checksums error when we are in
 bridge mode
Date: Mon, 14 Mar 2011 18:04:37 +0100
Message-ID: <1300122277.3423.132.camel@edumazet-laptop>
References: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45956 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab1CNRE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 13:04:58 -0400
Received: by fxm17 with SMTP id 17so3112388fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 10:04:57 -0700 (PDT)
In-Reply-To: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 17:08 +0100, Daniel Lezcano a =C3=A9crit :
> When the lower device has offloading capabilities, the packets checks=
ums
> are not computed. That leads to have any macvlan port in bridge mode =
to
> not work because the packets are dropped due to a bad checksum.
>=20
> If the macvlan is in bridge mode, the packet is forwarded to another
> macvlan port and reach the network stack where it looks for a checksu=
m
> but this one was not computed due to the offloading of the lower devi=
ce.
> In this case, we have to set the packet with CHECKSUM_UNNECESSARY
> when it is forwarded to a bridged port and restore the previous value=
 of
> ip_summed when the packet goes to the lowerdev.
>=20
> Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Andrian Nord <nightnord@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



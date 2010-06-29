From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] xfrm: remove export of xfrm4_rcv_encap.
Date: Tue, 29 Jun 2010 07:37:20 +0200
Message-ID: <1277789840.4235.1312.camel@edumazet-laptop>
References: <AANLkTimIJ_vhe7wwCqTrfjj4HUdrbpyrlAwnQGrtAiOk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45454 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab0F2Fh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 01:37:26 -0400
Received: by wwb18 with SMTP id 18so188024wwb.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 22:37:24 -0700 (PDT)
In-Reply-To: <AANLkTimIJ_vhe7wwCqTrfjj4HUdrbpyrlAwnQGrtAiOk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 juin 2010 =C3=A0 08:05 +0300, Rami Rosen a =C3=A9crit :
> Hi,
>  The patch removes EXPORT_SYMBOL of xfrm4_rcv_encap() method
>  as it is unneeded.
>=20
> Regards,
> Rami Rosen
>=20

This claim seems wrong. I wonder how you came to it.

CONFIG_INET_XFRM_TUNNEL=3Dm
CONFIG_XFRM_IPCOMP=3Dm
CONFIG_INET_IPCOMP=3Dm

ERROR: "xfrm4_rcv_encap" [net/ipv4/xfrm4_tunnel.ko] undefined!




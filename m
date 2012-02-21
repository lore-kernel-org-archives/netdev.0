From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] datagram: Add offset argument to __skb_recv_datagram
Date: Tue, 21 Feb 2012 18:40:32 +0100
Message-ID: <1329846032.18384.22.camel@edumazet-laptop>
References: <4F43D49E.3010401@parallels.com>
	 <4F43D4D2.5080903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51303 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab2BURkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:40:37 -0500
Received: by wgbdt10 with SMTP id dt10so5915487wgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:40:36 -0800 (PST)
In-Reply-To: <4F43D4D2.5080903@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 21:30 +0400, Pavel Emelyanov a =C3=
=A9crit :
> This one is only considered for MSG_PEEK flag and the value pointed b=
y
> it specifies where to start peeking bytes from. If the offset happens=
 to
> point into the middle of the returned skb, the offset within this skb=
 is
> put back to this very argument.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>  include/linux/skbuff.h |    2 +-
>  net/core/datagram.c    |   21 +++++++++++++--------
>  net/ipv4/udp.c         |    4 ++--
>  net/ipv6/udp.c         |    4 ++--
>  4 files changed, 18 insertions(+), 13 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

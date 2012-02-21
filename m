From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/6] unix: Support peeking offset for datagram and
 seqpacket sockets
Date: Tue, 21 Feb 2012 18:49:56 +0100
Message-ID: <1329846596.18384.26.camel@edumazet-laptop>
References: <4F43D49E.3010401@parallels.com>
	 <4F43D507.9010905@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33406 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab2BURuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:50:00 -0500
Received: by werb13 with SMTP id b13so3972014wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:49:59 -0800 (PST)
In-Reply-To: <4F43D507.9010905@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 21:31 +0400, Pavel Emelyanov a =C3=
=A9crit :
> The sk_peek_off manipulations are protected with the unix_sk->readloc=
k mutex.
> This mutex is enough since all we need is to syncronize setting the o=
ffset
> vs reading the queue head. The latter is fully covered with the menti=
oned lock.
>=20
> The recently added __skb_recv_datagram's offset is used to pick the s=
kb to
> read the data from.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>  net/unix/af_unix.c |   30 +++++++++++++++++++++++++-----
>  1 files changed, 25 insertions(+), 5 deletions(-)

Very nice !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

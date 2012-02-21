From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/6] unix: Support peeking offset for stream sockets
Date: Tue, 21 Feb 2012 18:51:19 +0100
Message-ID: <1329846679.18384.27.camel@edumazet-laptop>
References: <4F43D49E.3010401@parallels.com>
	 <4F43D516.9060102@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41673 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab2BURvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:51:24 -0500
Received: by werb13 with SMTP id b13so3973063wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:51:23 -0800 (PST)
In-Reply-To: <4F43D516.9060102@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 21:32 +0400, Pavel Emelyanov a =C3=
=A9crit :
> The same here -- we can protect the sk_peek_off manipulations with
> the unix_sk->readlock mutex.
>=20
> The peeking of data from a stream socket is done in the datagram styl=
e,
> i.e. even if there's enough room for more data in the user buffer, on=
ly
> the head skb's data is copied in there. This feature is preserved whe=
n
> peeking data from a given offset -- the data is read till the nearest
> skb's boundary.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

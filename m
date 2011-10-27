From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from
 TIME_WAIT
Date: Thu, 27 Oct 2011 06:30:08 +0200
Message-ID: <1319689808.3436.6.camel@edumazet-laptop>
References: <1319611331.18883.13.camel@edumazet-laptop>
	 <20111026.155908.1133603039272144196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60784 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab1J0EaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 00:30:18 -0400
Received: by wyg36 with SMTP id 36so2381396wyg.19
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 21:30:17 -0700 (PDT)
In-Reply-To: <20111026.155908.1133603039272144196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 octobre 2011 =C3=A0 15:59 -0400, David Miller a =C3=A9cr=
it :

> Did you happen to check to see that this does the right thing for
> V4 mapped ipv6 sockets?
>=20

This is handled by prior patch, and this new patch doesnt break it

(tw->tw_tclass is overwritten by tclass, only on true/AF_INET6 ipv6
sockets)

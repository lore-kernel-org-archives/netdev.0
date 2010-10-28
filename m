From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 18:33:54 +0200
Message-ID: <1288283634.11523.20.camel@edumazet-laptop>
References: <4CC99FDC.9070102@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32990 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756680Ab0J1QeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 12:34:01 -0400
Received: by wyf28 with SMTP id 28so2139310wyf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 09:34:00 -0700 (PDT)
In-Reply-To: <4CC99FDC.9070102@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 octobre 2010 =C3=A0 20:07 +0400, Pavel Emelyanov a =C3=A9cr=
it :
> commit e985aad7 (ip_gre: percpu stats accounting) forgot the fallback
> tunnel case (gre0).
>=20
> This is the 4th part of the "foo: fix percpu stats accounting" series=
 ;)
>=20
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>=20

Indeed, right you are ;)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Anyway, I suspect more work is needed...

(check patch against ixgbe : http://patchwork.ozlabs.org/patch/69458/ )




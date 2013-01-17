From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH 1/2] ipv4: Remove output route check in ipv4_mtu
Date: Thu, 17 Jan 2013 10:35:15 +0200
Message-ID: <20130117103515.338f5b1a@vostro>
References: <20130117065500.GG18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>,
	luky-37@hotmail.com, pupilla@libero.it, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:62400 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab3AQIfL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 03:35:11 -0500
Received: by mail-ee0-f51.google.com with SMTP id d17so1055266eek.24
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 00:35:09 -0800 (PST)
In-Reply-To: <20130117065500.GG18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2013 07:55:01 +0100 Steffen Klassert
<steffen.klassert@secunet.com> wrote:

> The output route check was introduced with git commit 261663b0
> (ipv4: Don't use the cached pmtu informations for input routes)
> during times when we cached the pmtu informations on the
> inetpeer. Now the pmtu informations are back in the routes,
> so this check is obsolete. It also had some unwanted side effects,
> as reported by Timo Teras and Lukas Tribus.
>=20
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---

Acked-by: Timo Ter=C3=A4s <timo.teras@iki.fi>

I think this should also go to stable queues which are applicable, sinc=
e
the original commit caused CLAMPMSS and XFRM pmtu regressions.

The original thread of this is:
http://marc.info/?t=3D134208398500001&r=3D1&w=3D2

My original revert request is at:
http://marc.info/?l=3Dlinux-netdev&m=3D134242561624266&w=3D2

and additional reasoning at:
http://marc.info/?l=3Dlinux-netdev&m=3D134243626627716&w=3D2

Thanks,
 Timo

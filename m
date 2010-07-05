From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tg3: 64bits stats
Date: Mon, 05 Jul 2010 18:03:00 +0200
Message-ID: <1278345780.2877.376.camel@edumazet-laptop>
References: <1278321242.2877.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44863 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab0GEQDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 12:03:13 -0400
Received: by fxm14 with SMTP id 14so3840655fxm.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 09:03:11 -0700 (PDT)
In-Reply-To: <1278321242.2877.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 11:14 +0200, Eric Dumazet a =C3=A9crit =
:
> After commit be1f3c2c027c (net: Enable 64-bit net device statistics o=
n
> 32-bit architectures), we can now provide 64bit stats, even on 32bit
> arches.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Please disregard this patch.

There is small possibility a reader might read a 64bit value while
another writer makes a change to it, changing high 32bit value.

A change in core network would be needed to make this 100% safe,
possibly using a seqlock to protect dev->stats64




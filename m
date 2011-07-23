From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6 v2] gre: fix improper error handling
Date: Sat, 23 Jul 2011 10:32:44 +0200
Message-ID: <1311409964.6669.9.camel@edumazet-laptop>
References: <201107231049.40603.xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33227 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1GWIcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 04:32:50 -0400
Received: by wyg8 with SMTP id 8so1901157wyg.19
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 01:32:49 -0700 (PDT)
In-Reply-To: <201107231049.40603.xeb@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 juillet 2011 =C3=A0 10:49 +0400, xeb@mail.ru a =C3=A9crit =
:
> Fix improper protocol err_handler, current implementation is fully
> unapplicable and may cause kernel crash due to double kfree_skb.
>=20
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> ---
> net/ipv4/gre.c |   21 ++++++---------------
>  1 files changed, 6 insertions(+), 15 deletions(-)
> =20

Good catch !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>





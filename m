From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 17:49:47 +0200
Message-ID: <1308584987.26922.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	 <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	stable@kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36312 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371Ab1FTNtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 09:49:51 -0400
Received: by wwe5 with SMTP id 5so2568472wwe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 06:49:50 -0700 (PDT)
In-Reply-To: <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 09:48 +0200, Richard Cochran a =C3=A9crit =
:
> Because the socket buffer is freed in the completion interrupt, it is=
 not
> safe to access it after submitting it to the hardware.
>=20
> Cc: stable@kernel.org
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/mv643xx_eth.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] dp83640: free packet queues on remove
Date: Wed, 19 Oct 2011 06:48:35 +0200
Message-ID: <1318999715.19139.21.camel@edumazet-laptop>
References: <cover.1318498805.git.richard.cochran@omicron.at>
	 <32e73bbe8141d803ebb58488e6cb60870bce4975.1318498805.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>, stable@kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52227 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab1JSEsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:48:41 -0400
Received: by wyg36 with SMTP id 36so1308717wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 21:48:40 -0700 (PDT)
In-Reply-To: <32e73bbe8141d803ebb58488e6cb60870bce4975.1318498805.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 11:46 +0200, Richard Cochran a =C3=A9cr=
it :
> If the PHY should disappear (for example, on an USB Ethernet MAC), th=
en
> the driver would leak any undelivered time stamp packets. This commit
> fixes the issue by calling the appropriate functions to free any pack=
ets
> left in the transmit and receive queues.
>=20
> The driver first appeared in v3.0.
>=20
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Cc: <stable@kernel.org>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

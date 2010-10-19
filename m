From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3 v2] net: cleanups in RX queue allocation
Date: Tue, 19 Oct 2010 10:13:21 +0200
Message-ID: <1287476001.2676.11.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010182056010.6676@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35751 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab0JSIN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 04:13:26 -0400
Received: by wwj40 with SMTP id 40so841018wwj.1
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 01:13:25 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010182056010.6676@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 octobre 2010 =C3=A0 21:00 -0700, Tom Herbert a =C3=A9crit :
> Clean up in RX queue allocation.  In netif_set_real_num_rx_queues
> return error on attempt to set zero queues, or requested number is
> greater than number of allocated queues.  In netif_alloc_rx_queues,
> do BUG_ON if queue_count is zero.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



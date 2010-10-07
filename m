From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Thu, 07 Oct 2010 08:16:39 +0200
Message-ID: <1286432199.9417.47.camel@edumazet-laptop>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	therbert@google.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53213 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab0JGGQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:16:49 -0400
Received: by fxm4 with SMTP id 4so172216fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 23:16:48 -0700 (PDT)
In-Reply-To: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 octobre 2010 =C3=A0 15:00 -0700, John Fastabend a =C3=A9cri=
t :
> The logic for netif_set_real_num_rx_queues is the following,
>=20


=2E..

> Because netif_set_real_num_rx_queues sets num_rx_queues if the
> reg state is not NETREG_REGISTERED we end up with the incorrect
> max number of rx queues. This patch proposes to remove the else
> clause above so this does not occur.  Also just reading the
> function set_real_num it seems a bit unexpected that num_rx_queues
> gets set.
>=20
> CC: Ben Hutchings <bhutchings@solarflare.com>
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



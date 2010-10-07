From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 23:35:25 -0700 (PDT)
Message-ID: <20101006.233525.02264748.davem@davemloft.net>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
	<1286432199.9417.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53805
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755432Ab0JGGfE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 02:35:04 -0400
In-Reply-To: <1286432199.9417.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Oct 2010 08:16:39 +0200

> Le lundi 04 octobre 2010 =E0 15:00 -0700, John Fastabend a =E9crit :
>> The logic for netif_set_real_num_rx_queues is the following,
>>=20
>=20
>=20
> ...
>=20
>> Because netif_set_real_num_rx_queues sets num_rx_queues if the
>> reg state is not NETREG_REGISTERED we end up with the incorrect
>> max number of rx queues. This patch proposes to remove the else
>> clause above so this does not occur.  Also just reading the
>> function set_real_num it seems a bit unexpected that num_rx_queues
>> gets set.
>>=20
>> CC: Ben Hutchings <bhutchings@solarflare.com>
>>=20
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

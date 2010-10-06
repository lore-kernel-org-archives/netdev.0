From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 13:41:16 -0700 (PDT)
Message-ID: <20101006.134116.115942855.davem@davemloft.net>
References: <1286379105.2371.15.camel@achroite.uk.solarflarecom.com>
	<20101006181458.GA6817@mcarlson.broadcom.com>
	<1286390945.9417.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52383
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755126Ab0JFUkz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 16:40:55 -0400
In-Reply-To: <1286390945.9417.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Oct 2010 20:49:05 +0200

> Le mercredi 06 octobre 2010 =E0 11:14 -0700, Matt Carlson a =E9crit :
>=20
>> Yes.  We were missing a call to this function in the legacy case.
>>=20
>>=20
>> [PATCH net-next] tg3: Set real_num_rx_queues for non-multiq devs
>>=20
>> Commit 2ddaad397c47de012dfb956b0c05540da1a0dde5 entitled "tg3: Use
>> netif_set_real_num_{rx,tx}_queues()" added a new call to
>> netif_set_real_num_rx_queues in tg3_enable_msix().  This call also n=
eeds
>> to be added to the legacy path to correctly reflect the actual numbe=
r of
>> rx queues.
>>=20
>> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
=2E..
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

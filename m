From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 16:05:48 -0400 (EDT)
Message-ID: <20130318.160548.1629790231912790279.davem@davemloft.net>
References: <1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130318.131318.138158829629301794.davem@davemloft.net>
	<CAHo-OoxaaLLXtAZcx99m7p5=Hez3gpUWxvoQAgksyG3PRZH-Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, dmitry@broadcom.com,
	netdev@vger.kernel.org, yuvalmin@broadcom.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3CRUFv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 16:05:51 -0400
In-Reply-To: <CAHo-OoxaaLLXtAZcx99m7p5=Hez3gpUWxvoQAgksyG3PRZH-Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 18 Mar 2013 12:54:49 -0700

> I've reproduced this in the lab.
>=20
> I can confirm this patch fixes per-queue statistics (ie. ethtool -S
> "[0]: tx_bytes") - which previously were not monotonically increasing=
=2E
> However there is still a bug wrt. global device stats (ie. ethtool -S
> "tx_bytes" and /proc/net/dev transmit bytes).
> I'm guessing there's another similar bug later on during aggregation.
>=20
> I expect to find the offending code and send out a patch soon.

Thanks Maciej.

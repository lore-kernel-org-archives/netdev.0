From: David Miller <davem@davemloft.net>
Subject: Re: KERNEL: assertion ((int)tp->sacked_out >= 0) failed at
 net/ipv4/tcp_input.c (2626)
Date: Wed, 28 Mar 2007 12:06:04 -0700 (PDT)
Message-ID: <20070328.120604.38712657.davem@davemloft.net>
References: <460A5988.2050403@trash.net>
	<Pine.LNX.4.64.0703281543460.14473@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965680AbXC1TGF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 15:06:05 -0400
In-Reply-To: <Pine.LNX.4.64.0703281543460.14473@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 28 Mar 2007 16:24:40 +0300 (EEST)

> It seems I'm being guilty to this one, Dave please apply to net-2.6.2=
2=20
> (besides this I think the tcp_sync_left_out should be changed but I'l=
l=20
> prepare a patch for that later). Btw, how should this kind of email w=
ith=20
> some non-patch description+patch be formatted?).

Thanks for figuring out the problem so quickly, this formatting
is fine.

> [PATCH] [TCP]: Timedout loop must skip SACKed skbs too while marking
>=20
> Marking skb with both S and L is invalid, and that could easily
> happen in the timedout loop. Later on the tcp_sync_left_out
> reduces sacked_out if lost_out + sacked_out > packets_out and
> then eventually sacked_out underflows triggering a debug trap in
> tcp_clean_rtx_queue.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Patch applied, thanks a lot!

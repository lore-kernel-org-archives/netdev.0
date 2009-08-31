From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next-2.6] drivers: Kill now superfluous ->last_rx
	stores
Date: Mon, 31 Aug 2009 13:37:10 -0400
Message-ID: <20090831173710.GC2105@hmsreliant.think-freely.org>
References: <4A9B6963.5090207@cn.fujitsu.com> <4A9B6E57.7090703@gmail.com> <20090831111245.GA2105@hmsreliant.think-freely.org> <4A9BD13E.4040501@gmail.com> <4A9BFBAA.10705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51519 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678AbZHaRhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 13:37:16 -0400
Content-Disposition: inline
In-Reply-To: <4A9BFBAA.10705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 06:34:50PM +0200, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
> > Neil Horman a =E9crit :
> >> I still see a large number of drivers that update dev->last_rx, al=
though its
> >> not all as I look through the list, so something definately seems =
amiss.
> >=20
> > Some drivers still update dev->last_rx for their own needs, not a c=
ore
> > network concern.
> >=20
> > But a cleanup is certainly possible on few other drivers, about a d=
ozen
> > if I count correctly.
>=20
> Well, a litle bit more if we look outside of drivers/net
>=20
> [PATCH net-next-2.6] drivers: Kill now superfluous ->last_rx stores
>=20
> The generic packet receive code takes care of setting
> netdev->last_rx when necessary, for the sake of the
> bonding ARP monitor.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Neil Horman <nhorman@txudriver.com>

Thanks!
Neil


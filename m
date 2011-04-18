From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: chelsio: convert to hw_features
Date: Sun, 17 Apr 2011 17:42:53 -0700 (PDT)
Message-ID: <20110417.174253.55863007.davem@davemloft.net>
References: <20110417101546.EE73713A67@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55210
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753112Ab1DRAn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:43:28 -0400
In-Reply-To: <20110417101546.EE73713A67@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sun, 17 Apr 2011 12:15:46 +0200 (CEST)

> @@ -1369,6 +1369,7 @@ static void sge_rx(struct sge *sge, struct free=
lQ *fl, unsigned int len)
>  	const struct cpl_rx_pkt *p;
>  	struct adapter *adapter =3D sge->adapter;
>  	struct sge_port_stats *st;
> +	struct net_device *dev =3D adapter->port[p->iff].dev;
> =20
>  	skb =3D get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad);
>  	if (unlikely(!skb)) {

You're now using 'p' before it gets initialzed.

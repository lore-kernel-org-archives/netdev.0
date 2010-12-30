From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4] Gemini: Gigabit ethernet driver
Date: Thu, 30 Dec 2010 10:48:21 +0100
Message-ID: <20101230094821.GA24281@rere.qmqm.pl>
References: <20101230083905.5A8EB13909@rere.qmqm.pl> <1293700797.2400.13.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45433 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab0L3JsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 04:48:23 -0500
Content-Disposition: inline
In-Reply-To: <1293700797.2400.13.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 30, 2010 at 01:19:57AM -0800, Joe Perches wrote:
> On Thu, 2010-12-30 at 09:39 +0100, Micha=B3 Miros=B3aw wrote:
> > Driver for SL351x (Gemini) SoC ethernet peripheral. Based in part
> > on work by Paulius Zaleckas and GPLd code from Raidsonic and other
> > NAS vendors.
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > diff --git a/drivers/net/sl351x.c b/drivers/net/sl351x.c
>=20
> Output trivia:
>=20
> > +static void gmac_tx_interrupt(struct net_device *dev, unsigned txq=
_num)
> []
> > +	netif_info(gmac, tx_done, dev, "txirq%u: %u,%u,%u\n",
> > +		txq_num, txq->cptr, GET_RPTR(ptr_reg), GET_WPTR(ptr_reg));
>=20
> pointers as decimal?
> There seems to be a lot of output using %u where I expected %08x.

These are indexes into TX/RX/RXbuf(FreeQ) rings. It's usually easier to=
 read
them in decimal by humans. ;) I kept the notation of 'PTR' from the ori=
ginal
hardware register names.

Best Regards,
Micha=B3 Miros=B3aw

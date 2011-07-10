From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 00/21] clean up rx_copybreak handling [split version]
Date: Sun, 10 Jul 2011 13:28:18 +0200
Message-ID: <20110710112818.GA24325@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
 <1310235632.3848.13.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Tim Hockin <thockin@hockin.org>,
	Don Fry <pcnet32@frontier.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ion Badulescu <ionut@badula.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Dillow <dave@thedillows.org>,
	Roger Luethi <rl@hellgate.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58403 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756068Ab1GJL2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 07:28:19 -0400
Content-Disposition: inline
In-Reply-To: <1310235632.3848.13.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2011 at 11:20:32AM -0700, Joe Perches wrote:
> On Sat, 2011-07-09 at 19:17 +0200, Micha=B3 Miros=B3aw wrote:
> > Split version of rx_copybreak cleanup patch.
>=20
> Hello Micha=B3.
>=20
> Looks good, thanks for doing this work.
>=20
> One style quibble.
>=20
> You use this style:
>=20
> +			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
> +				pkt_len, rx_copybreak,
> +				&np->pci_dev->dev,
> +				le32_to_cpu(desc->frag[0].addr),
> +				np->rx_buf_sz);
>=20
> where almost all other uses throughout drivers/net
> align arguments to open parenthesis instead.
>=20
> +			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
> +						    pkt_len, rx_copybreak,
> +						    &np->pci_dev->dev,
> +						    le32_to_cpu(desc->frag[0].addr),
> +						    np->rx_buf_sz);

I'll fix that in v2 where the style differs.

Best Regards,
Micha=B3 Miros=B3aw

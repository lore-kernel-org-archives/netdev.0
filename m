From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 00/21] clean up rx_copybreak handling [split version]
Date: Sun, 10 Jul 2011 13:52:06 +0200
Message-ID: <20110710115206.GA24395@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
 <1310235632.3848.13.camel@Joe-Laptop>
 <20110710112818.GA24325@rere.qmqm.pl>
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
Received: from rere.qmqm.pl ([89.167.52.164]:46950 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754870Ab1GJLwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 07:52:08 -0400
Content-Disposition: inline
In-Reply-To: <20110710112818.GA24325@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2011 at 01:28:18PM +0200, Micha=B3 Miros=B3aw wrote:
> On Sat, Jul 09, 2011 at 11:20:32AM -0700, Joe Perches wrote:
> > On Sat, 2011-07-09 at 19:17 +0200, Micha=B3 Miros=B3aw wrote:
> > > Split version of rx_copybreak cleanup patch.
> >=20
> > Hello Micha=B3.
> >=20
> > Looks good, thanks for doing this work.
> >=20
> > One style quibble.
> >=20
> > You use this style:
> >=20
> > +			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
> > +				pkt_len, rx_copybreak,
> > +				&np->pci_dev->dev,
> > +				le32_to_cpu(desc->frag[0].addr),
> > +				np->rx_buf_sz);
> >=20
> > where almost all other uses throughout drivers/net
> > align arguments to open parenthesis instead.
> >=20
> > +			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
> > +						    pkt_len, rx_copybreak,
> > +						    &np->pci_dev->dev,
> > +						    le32_to_cpu(desc->frag[0].addr),
> > +						    np->rx_buf_sz);
>=20
> I'll fix that in v2 where the style differs.

I modified patches where surrounding code had been consistent. I'm now
convinced I don't like this style, especially when combined with 80-col=
umn
limit and no limit on indentation levels.

Best Regards,
Micha=B3 Miros=B3aw

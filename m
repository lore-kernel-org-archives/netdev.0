From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/21] clean up rx_copybreak handling [split version]
Date: Sun, 10 Jul 2011 08:11:20 -0700
Message-ID: <1310310680.3848.29.camel@Joe-Laptop>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
	 <1310235632.3848.13.camel@Joe-Laptop> <20110710112818.GA24325@rere.qmqm.pl>
	 <20110710115206.GA24395@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3776 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794Ab1GJPLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 11:11:22 -0400
In-Reply-To: <20110710115206.GA24395@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-07-10 at 13:52 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Sun, Jul 10, 2011 at 01:28:18PM +0200, Micha=C5=82 Miros=C5=82aw w=
rote:
> > On Sat, Jul 09, 2011 at 11:20:32AM -0700, Joe Perches wrote:
> > > where almost all other uses throughout drivers/net
> > > align arguments to open parenthesis instead.
> > > +			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
> > > +						    pkt_len, rx_copybreak,
> > > +						    &np->pci_dev->dev,
> > > +						    le32_to_cpu(desc->frag[0].addr),
> > > +						    np->rx_buf_sz);
> > I'll fix that in v2 where the style differs.
> I modified patches where surrounding code had been consistent. I'm no=
w
> convinced I don't like this style, especially when combined with 80-c=
olumn
> limit and no limit on indentation levels.

Heh.

It truly can be a bad form when combined with
long variable or function names or multiple
indirections or string constants, etc.

I chose to ignore 80 columns on the
"le32_to_cpu(desc->frag[0].addr)," argument to
dev_skb_finish_rx_dma.

It can look hideous when slavish to 80 columns.

=46eel free to ignore those checkpatch warnings
when you think appropriate.

cheers, Joe


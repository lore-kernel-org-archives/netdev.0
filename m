From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/21] clean up rx_copybreak handling [split version]
Date: Sat, 09 Jul 2011 11:20:32 -0700
Message-ID: <1310235632.3848.13.camel@Joe-Laptop>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
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
Received: from mail.perches.com ([173.55.12.10]:3704 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753925Ab1GISUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 14:20:34 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-07-09 at 19:17 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> Split version of rx_copybreak cleanup patch.

Hello Micha=C5=82.

Looks good, thanks for doing this work.

One style quibble.

You use this style:

+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+				pkt_len, rx_copybreak,
+				&np->pci_dev->dev,
+				le32_to_cpu(desc->frag[0].addr),
+				np->rx_buf_sz);

where almost all other uses throughout drivers/net
align arguments to open parenthesis instead.

+			skb =3D dev_skb_finish_rx_dma(&np->rx_skbuff[entry],
+						    pkt_len, rx_copybreak,
+						    &np->pci_dev->dev,
+						    le32_to_cpu(desc->frag[0].addr),
+						    np->rx_buf_sz);



From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 01/75] net: add APIs for manipulating skb page fragments.
Date: Wed, 24 Aug 2011 17:15:19 -0400
Message-ID: <20110824211519.GA28813@dumpdata.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
 <1313760467-8598-1-git-send-email-ian.campbell@citrix.com>
 <20110824182113.GF15675@dumpdata.com>
 <1314220141.17978.693.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:39355 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab1HXVPh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 17:15:37 -0400
Content-Disposition: inline
In-Reply-To: <1314220141.17978.693.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 10:09:01PM +0100, Ian Campbell wrote:
> On Wed, 2011-08-24 at 19:21 +0100, Konrad Rzeszutek Wilk wrote:
> > On Fri, Aug 19, 2011 at 02:26:33PM +0100, Ian Campbell wrote:
> > > The primary aim is to add skb_frag_(ref|unref) in order to remove=
 the use of
> > > bare get/put_page on SKB pages fragments and to isolate users fro=
m subsequent
> > > changes to the skb_frag_t data structure.
> > >=20
> > > Also included are helper APIs for passing a paged fragment to kma=
p and
> > > dma_map_page since I was seeing the same pattern a lot. A helper =
for
> > > pci_map_page is ommitted due to Micha=C5=82 Miros=C5=82aw's recom=
mendation that users
> > > should transition to pci_map_page instead.
> >=20
> > You mean "transition to dma_map_page instead." ?
>=20
> That's right, oops.

With a big pot of tea next to me to keep me sharp I took look at all
75 patches and besides this comment and the 'XXX' (which I already emai=
led
you about it - it also shows up in "36/75] myri10ge: convert to SKB pag=
ed frag API.")
they all looked OK to me.

So you can stick 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracl=
e.com>'
on all of them if you would like.

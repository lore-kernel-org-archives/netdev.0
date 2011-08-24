From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 01/75] net: add APIs for manipulating skb page
 fragments.
Date: Wed, 24 Aug 2011 22:09:01 +0100
Message-ID: <1314220141.17978.693.camel@dagon.hellion.org.uk>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	 <1313760467-8598-1-git-send-email-ian.campbell@citrix.com>
	 <20110824182113.GF15675@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110824182113.GF15675@dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-24 at 19:21 +0100, Konrad Rzeszutek Wilk wrote:
> On Fri, Aug 19, 2011 at 02:26:33PM +0100, Ian Campbell wrote:
> > The primary aim is to add skb_frag_(ref|unref) in order to remove t=
he use of
> > bare get/put_page on SKB pages fragments and to isolate users from =
subsequent
> > changes to the skb_frag_t data structure.
> >=20
> > Also included are helper APIs for passing a paged fragment to kmap =
and
> > dma_map_page since I was seeing the same pattern a lot. A helper fo=
r
> > pci_map_page is ommitted due to Micha=C5=82 Miros=C5=82aw's recomme=
ndation that users
> > should transition to pci_map_page instead.
>=20
> You mean "transition to dma_map_page instead." ?

That's right, oops.

Ian.

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 01/75] net: add APIs for manipulating skb page fragments.
Date: Wed, 24 Aug 2011 14:21:13 -0400
Message-ID: <20110824182113.GF15675@dumpdata.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
 <1313760467-8598-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1313760467-8598-1-git-send-email-ian.campbell@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2011 at 02:26:33PM +0100, Ian Campbell wrote:
> The primary aim is to add skb_frag_(ref|unref) in order to remove the=
 use of
> bare get/put_page on SKB pages fragments and to isolate users from su=
bsequent
> changes to the skb_frag_t data structure.
>=20
> Also included are helper APIs for passing a paged fragment to kmap an=
d
> dma_map_page since I was seeing the same pattern a lot. A helper for
> pci_map_page is ommitted due to Micha=C5=82 Miros=C5=82aw's recommend=
ation that users
> should transition to pci_map_page instead.

You mean "transition to dma_map_page instead." ?

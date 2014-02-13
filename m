From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw
 MAC address
Date: Thu, 13 Feb 2014 11:35:21 +0000
Message-ID: <1392291321.27366.17.camel@kazak.uk.xensource.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
	 <1392108205.22033.16.camel@dagon.hellion.org.uk>
	 <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
	 <1392203708.13563.50.camel@kazak.uk.xensource.com>
	 <CAB=NE6WFDWW1faoCYJP9zh6rPPvET+dbHxjHnGkYXtRx6z2LOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6WFDWW1faoCYJP9zh6rPPvET+dbHxjHnGkYXtRx6z2LOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-02-12 at 14:05 -0800, Luis R. Rodriguez wrote:
> > I meant the PV protocol extension which allows guests (netfront) to
> > register to receive multicast frames across the PV ring -- i.e. for
> > multicast to work from the guests PoV.
> 
> Not quite sure I understand, ipv6 works on guests so multicast works,
> so its unclear what you mean by multicast frames across the PV ring.
> Is there any code or or documents I can look at ?

xen/include/public/io/netif.h talks about 'feature-multicast-control'
and XEN_NETIF_EXTRA_TYPE_MCAST_{ADD,DEL}.

Looking at it now in the absence of those then flooding is the
default...

> > (maybe that was just an optimisation though and the default is to flood
> > everything, it was a long time ago)
> 
> From a networking perspective everything is being flooded as I've seen
> it so far.

... which is why it works ;-)

Ian.

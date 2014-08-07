From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: Modular 6LoWPAN? (was: Re: 6lowpan: introduce new net/6lowpan
 directory)
Date: Thu, 7 Aug 2014 15:26:09 +0200
Message-ID: <20140807132606.GB17452@omega>
References: <CAMuHMdXnGXGqy7B2-wujVxUPA9+3ZfYhcdKb6_jpDV4P7_KMxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-bluetooth@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-wpan@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdXnGXGqy7B2-wujVxUPA9+3ZfYhcdKb6_jpDV4P7_KMxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 07, 2014 at 02:37:38PM +0200, Geert Uytterhoeven wrote:
> Hi Alexander,
> 
> On Wed, Aug 6, 2014 at 6:46 PM, Linux Kernel Mailing List
> <linux-kernel@vger.kernel.org> wrote:
> > Gitweb:     http://git.kernel.org/linus/;a=commit;h=2c6bed7cfcd3f594ed9e4d6919fa2ebea2243d19
> > Commit:     2c6bed7cfcd3f594ed9e4d6919fa2ebea2243d19
> > Parent:     6c53823ae0e10e723131055e1e65dd6a328a228e
> > Refname:    refs/heads/master
> > Author:     Alexander Aring <alex.aring@gmail.com>
> > AuthorDate: Fri Jul 11 10:24:18 2014 +0200
> > Committer:  Marcel Holtmann <marcel@holtmann.org>
> > CommitDate: Sat Jul 12 01:53:30 2014 +0200
> >
> >     6lowpan: introduce new net/6lowpan directory
> >
> >     This patch moves generic code which is used by bluetooth and ieee802154
> >     6lowpan to a new net/6lowpan directory. This directory contains generic
> >     6LoWPAN code which is shared between bluetooth and ieee802154 MAC-Layer.
> >
> >     This is the IPHC - "IPv6 Header Compression" format at the moment. Which
> >     is described by RFC 6282 [0]. The BLTE 6LoWPAN draft describes that the
> >     IPHC is the same format like IEEE 802.15.4, see [1].
> >
> >     Futuremore we can put more code into this directory which is shared
> >     between BLTE and IEEE 802.15.4 6LoWPAN like RFC 6775 or the routing
> >     protocol RPL RFC 6550.
> >
> >     To avoid naming conflicts I renamed 6lowpan-y to ieee802154_6lowpan-y
> >     in net/ieee802154/Makefile.
> >
> >     [0] http://tools.ietf.org/html/rfc6282
> >     [1] http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12#section-3.2
> >     [2] http://tools.ietf.org/html/rfc6775
> >     [3] http://tools.ietf.org/html/rfc6550
> >
> >     Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> >     Acked-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> >     Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
> 
> > --- /dev/null
> > +++ b/net/6lowpan/Kconfig
> > @@ -0,0 +1,6 @@
> > +config 6LOWPAN
> > +       bool "6LoWPAN Support"
> 
> Is there any specific reason 6LOWPAN is bool instead of tristate?
> IPV6 can be modular.
> 
Indeed this can be modular. I see no special reason why it should not be
tristate. Sorry, that I didn't see this. Can you please send patches to
change it?

Thanks.

- Alex

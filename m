From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 9 Sep 2010 22:37:48 +0900
Message-ID: <002401cb5024$5a2044a0$66f8800a@maildom.okisemi.com>
References: <4C81019E.1010808@dsn.okisemi.com><4C8123D6.8020001@suse.cz><003901cb4f5d$bf977c80$66f8800a@maildom.okisemi.com><4C879AAB.6000905@suse.cz> <20100908075545.79023fa9@nehalam>
Cc: "Randy Dunlap" <randy.dunlap@oracle.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"ML netdev" <netdev@vger.kernel.org>,
	"MeeGo" <meego-dev@meego.com>, "Maxime Bizon" <mbizon@freebox.fr>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"John Linn" <john.linn@xilinx.com>,
	"Joe Perches" <joe@perches.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Jiri Slaby" <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:24640 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752169Ab0IINi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Sep 2010 07:55:45 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> Better yet:
> rxdr->count = clamp_val(ring->rx_pending,
> PCH_GBE_MIN_RXD,
> PCH_GBE_MAX_RXD);

Hi Stephen

Thank you for your suggestion.
I will modify like your suggestion.
.
Thanks, Ohtake
----- Original Message ----- 
From: "Stephen Hemminger" <shemminger@vyatta.com>
To: "Jiri Slaby" <jslaby@suse.cz>
Cc: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>; "Randy Dunlap" <randy.dunlap@oracle.com>; "Ralf Baechle"
<ralf@linux-mips.org>; "ML netdev" <netdev@vger.kernel.org>; "MeeGo" <meego-dev@meego.com>; "Maxime Bizon"
<mbizon@freebox.fr>; "LKML" <linux-kernel@vger.kernel.org>; "Kristoffer Glembo" <kristoffer@gaisler.com>; "John Linn"
<john.linn@xilinx.com>; "Joe Perches" <joe@perches.com>; "Greg Rose" <gregory.v.rose@intel.com>; "David S. Miller"
<davem@davemloft.net>; "Wang, Yong Y" <yong.y.wang@intel.com>; "Wang, Qi" <qi.wang@intel.com>; "Toshiharu Okada"
<okada533@dsn.okisemi.com>; "Tomoya Morinaga" <morinaga526@dsn.okisemi.com>; "Takahiro Shimizu"
<shimizu394@dsn.okisemi.com>; "Intel OTC" <joel.clark@intel.com>; "Foster, Margie" <margie.foster@intel.com>; "Andrew"
<andrew.chih.howe.khor@intel.com>
Sent: Wednesday, September 08, 2010 11:55 PM
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH


> On Wed, 08 Sep 2010 16:16:11 +0200
> Jiri Slaby <jslaby@suse.cz> wrote:
>
> > >>> +
> > >>> + rxdr->count = max(ring->rx_pending, (u32) PCH_GBE_MIN_RXD);
> > >>> + rxdr->count = min(rxdr->count, (u32) PCH_GBE_MAX_RXD);
> > >>
> > >> clamp()
> > >> And why you need the cast?
> > >
> > > [masa]
> > > Since warning appears at the time of a make.
> >
> > OK, then you have type error which you should fix instead. Perhaps
> > define the constnts with U suffix?
>
> Better yet:
> rxdr->count = clamp_val(ring->rx_pending,
> PCH_GBE_MIN_RXD,
> PCH_GBE_MAX_RXD);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>




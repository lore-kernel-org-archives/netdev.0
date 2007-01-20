From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Sat, 20 Jan 2007 18:15:54 -0200
Message-ID: <20070120201554.GC5037@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:44249 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965368AbXATUTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jan 2007 15:19:13 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending, apparently the first message got dropped somehow...

From: Marcelo Tosatti <marcelo@kvack.org>
Date: Thu, 18 Jan 2007 13:02:13 -0200
To: Jiri Benc <jbenc@suse.cz>
Cc: Dan Williams <dcbw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
In-Reply-To: <20070117164328.47ab60da@griffin.suse.cz>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)

Hi Jiri,

On Wed, Jan 17, 2007 at 04:43:28PM +0100, Jiri Benc wrote:
> On Wed, 17 Jan 2007 10:01:12 -0500, Dan Williams wrote:
> > But could we please be constructive here, and actually take a look at
> > the driver and point out problems?
> 
> Just from a quick glance:
> 
> - drivers/net/wireless/libertas/radiotap.h file with a lot of constants
>   already defined elsewhere (and not respecting kernel coding style,
>   either)

Such as? The bit definitions (IEEE80211_RADIOTAP_F_{TX,RX}...) have been
moved to include/net/ieee80211_radiotap.h in the second version of the
patch. Is that what you were referring to?

As for kernel coding style in that file, can you specify what looks
wrong? It appears alright to me.

> - regulatory domain management (already in ieee80211, in progress for
>   d80211)
> - the full authentication and association state machine (or am I
>   understanding it wrong?) 

> And I'm omitting things like
> 
> > +/** Double-Word(32Bit) Bit definition */
> > +#define DW_BIT_0	0x00000001
> > +#define DW_BIT_1	0x00000002
> > +#define DW_BIT_2	0x00000004
> > +#define DW_BIT_3	0x00000008
> > +#define DW_BIT_4	0x00000010
> > +#define DW_BIT_5	0x00000020
> > +#define DW_BIT_6	0x00000040
> > +#define DW_BIT_7	0x00000080
> > +#define DW_BIT_8	0x00000100
> > +#define DW_BIT_9	0x00000200
> > +#define DW_BIT_10	0x00000400
> > +#define DW_BIT_11       0x00000800
> > +#define DW_BIT_12       0x00001000
> > +#define DW_BIT_13       0x00002000
> > +#define DW_BIT_14       0x00004000
> > +#define DW_BIT_15       0x00008000
> > +#define DW_BIT_16       0x00010000
> > +#define DW_BIT_17       0x00020000
> > +#define DW_BIT_18       0x00040000
> > +#define DW_BIT_19       0x00080000
> > +#define DW_BIT_20       0x00100000
> > +#define DW_BIT_21       0x00200000
> > +#define DW_BIT_22       0x00400000
> > +#define DW_BIT_23       0x00800000
> > +#define DW_BIT_24       0x01000000
> > +#define DW_BIT_25       0x02000000
> > +#define DW_BIT_26       0x04000000
> > +#define DW_BIT_27       0x08000000
> > +#define DW_BIT_28       0x10000000
> > +#define DW_BIT_29       0x20000000
> > +#define DW_BIT_30	0x40000000
> > +#define DW_BIT_31	0x80000000

Removed.

> or those ENTER and LEAVE statements in each other function,

What is the problem with it? The entry/exit debug points have been
pretty useful for debugging. A bunch of in-tree drivers contain similar
code.

You might argue that ENTER/LEAVE should be in lower caps?

> non-conforming coding style, 

Send patches or point them out? :) 

I've ran scripts/Lindent over it, but there might still be some sections
in need of love.

> comments like "All rights reserved" or
> "This software file (the "File") is distributed by Marvell
> International Ltd.",

Removed them all, moved the Marvell copyright + GNU header to LICENSE
file.

> a lot of duplicated code, etc. 

Again, please point it out.

> I stopped looking t it in the half, asorry.

Thanks for your comments so far!

----- End forwarded message -----

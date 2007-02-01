From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 31 Jan 2007 22:58:51 -0200
Message-ID: <20070201005851.GA16279@dmt>
References: <20070120201554.GC5037@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, Dan Williams <dcbw@redhat.com>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Marcelo Tosatti <marcelo@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:53240 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161149AbXBABC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 20:02:26 -0500
Content-Disposition: inline
In-Reply-To: <20070120201554.GC5037@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

On Sat, Jan 20, 2007 at 06:15:54PM -0200, Marcelo Tosatti wrote:
> On Wed, Jan 17, 2007 at 04:43:28PM +0100, Jiri Benc wrote:
> > On Wed, 17 Jan 2007 10:01:12 -0500, Dan Williams wrote:
> > > But could we please be constructive here, and actually take a look at
> > > the driver and point out problems?
> > 
> > Just from a quick glance:
> > 
> > - drivers/net/wireless/libertas/radiotap.h file with a lot of constants
> >   already defined elsewhere (and not respecting kernel coding style,
> >   either)
> 
> Such as? The bit definitions (IEEE80211_RADIOTAP_F_{TX,RX}...) have been
> moved to include/net/ieee80211_radiotap.h in the second version of the
> patch. Is that what you were referring to?

I also converted the last piece of code which could be shared from
generic Linux code in radiotap.h, which is "struct ieee80211_hdr_4addr".

Can you go over it again and point any problems you might see? 

http://git.infradead.org/?p=libertas-2.6.git;a=blob;h=5d118f40cfbc43206369ec77082e220822318f11;hb=6a2277e41e4fd69e4f33cc7abc574aca8bca8abe;f=drivers/net/wireless/libertas/radiotap.h

> As for kernel coding style in that file, can you specify what looks
> wrong? It appears alright to me.

Again, coding style looks fine to me.

> > - regulatory domain management (already in ieee80211, in progress for
> >   d80211)
> > - the full authentication and association state machine (or am I
> >   understanding it wrong?) 

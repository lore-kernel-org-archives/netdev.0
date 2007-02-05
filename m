From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Mon, 5 Feb 2007 15:42:13 +0000
Message-ID: <20070205154212.GA25185@infradead.org>
References: <20070116185524.GA5681@dmt> <200701270253.08320.arnd@arndb.de> <20070203224349.GA18418@dmt> <20070205140147.GA17286@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@kvack.org>, Arnd Bergmann <arnd@arndb.de>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34514 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbXBEPmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:42:23 -0500
Content-Disposition: inline
In-Reply-To: <20070205140147.GA17286@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 09:01:47AM -0500, John W. Linville wrote:
> > to identify firmware problems on field.
> 
> I'm not too fond of the ENTER/LEAVE stuff either.  But, I do sympathize
> that they _can_ be useful in certain circumstances/workflows/whatever.
> 
> Is there an official "party line" on this documented somewhere
> (i.e. CodingStyle or elsewhere)?  A quick search doesn't reveal one
> to me.

We don't want this generally.  It's trivial to imlement this kind of
thing using gcc mcount instrumentation, but no one managed to submit
a generic implementation of this yet.  acme is hacking on some cool
tools to make similar things possible.  acme, any chance you might
have a cool idea about something based on ostra that we could merge
to allow people to do this without messing up the source code [1].

[1] yes, the l33t crowd would call this aspect oriented programming,
	I'd cool this cool and useful tool :)


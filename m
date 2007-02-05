From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Mon, 5 Feb 2007 09:01:47 -0500
Message-ID: <20070205140147.GA17286@tuxdriver.com>
References: <20070116185524.GA5681@dmt> <200701270253.08320.arnd@arndb.de> <20070203224349.GA18418@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Marcelo Tosatti <marcelo@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4987 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932968AbXBEOor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 09:44:47 -0500
Content-Disposition: inline
In-Reply-To: <20070203224349.GA18418@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 03, 2007 at 08:43:49PM -0200, Marcelo Tosatti wrote:
> On Sat, Jan 27, 2007 at 02:53:07AM +0100, Arnd Bergmann wrote:
> > On Tuesday 16 January 2007 19:55, Marcelo Tosatti wrote:

> > > +#define	ENTER()			dprintk(1, "Enter: %s, %s:%i\n", __FUNCTION__, \
> > > +							__FILE__, __LINE__)
> > > +#define	LEAVE()			dprintk(1, "Leave: %s, %s:%i\n", __FUNCTION__, \
> > > +							__FILE__, __LINE__)
> > 
> > As mentioned, these should probably just be removed
> 
> I disagree, entry/exit points have been shown to be useful in practice
> to identify firmware problems on field.

I'm not too fond of the ENTER/LEAVE stuff either.  But, I do sympathize
that they _can_ be useful in certain circumstances/workflows/whatever.

Is there an official "party line" on this documented somewhere
(i.e. CodingStyle or elsewhere)?  A quick search doesn't reveal one
to me.

John
-- 
John W. Linville
linville@tuxdriver.com

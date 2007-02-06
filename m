From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 6 Feb 2007 20:42:07 -0200
Message-ID: <20070206224207.GA4110@dmt>
References: <20070116185524.GA5681@dmt> <200701270253.08320.arnd@arndb.de> <20070203224349.GA18418@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:45863 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030210AbXBFWpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 17:45:41 -0500
Content-Disposition: inline
In-Reply-To: <20070203224349.GA18418@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 03, 2007 at 08:43:49PM -0200, Marcelo Tosatti wrote:
> Hi Arnd,

> > Most of these are unused as well, I guess it would be good
> > to go through the whole list and see what can be removed.
> 
> Done. Will go through the entire file list before posting the next
> patch.

Done.

> > Did you run the file through a recent sparse successfully?
> 
> Spits a bunch of warnings, looking at them.

Fixed sparse warnings.

> > The printk and dprintk statements should probably be converted
> > to dev_info/dev_dbg/... standard macros, or something derived
> > from that.

Done.

> > 
> > > +void if_usb_free(struct usb_card_rec *cardp)
> > > +{
> > > +	ENTER();
> > 
> > Do you find the ENTER() and LEAVE() macros really useful?
> > usually, you're better off taking them out...
> 
> Yes, for instance the bug reported at http://dev.laptop.org/ticket/841
> could be verified by checking the log file (by confirming that certain
> states were true/false).
> 
> However, only a few such macros, on key functions, are required. I'll go
> over and remove the unneeded ones.

Removed a bunch of ENTER/LEAVE macro calls.


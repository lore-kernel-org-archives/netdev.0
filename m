From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 22:29:23 -0500
Message-ID: <1169177364.2781.12.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <1169020333.9175.15.camel@johannes.berg> <20070117184204.GA3899@dmt>
	 <20070117230654.GA9387@infradead.org>
	 <1169134905.2788.16.camel@localhost.localdomain>
	 <20070118224008.GA6675@infradead.org>
	 <9e4733910701181454k3d01f018hddbe0568d14f6d8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Marcelo Tosatti <marcelo@kvack.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964812AbXASD1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:27:55 -0500
To: Jon Smirl <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701181454k3d01f018hddbe0568d14f6d8f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-18 at 17:54 -0500, Jon Smirl wrote:
> On 1/18/07, Christoph Hellwig <hch@infradead.org> wrote:
> > On Thu, Jan 18, 2007 at 10:41:45AM -0500, Dan Williams wrote:
> > > In the future we'll likely need some layering to support the 8385
> > > SDIO/CF variant, but most likely not in way the USB support is currently
> > > excessively layered and abstracted.
> >
> > Yeah.  Let's summarize my unfortunately a bit too nasty comments and
> > your more helpfull replies :-)
> >
> > This driver still needs a lot more work, both to cleanup a lot of crap
> > and integrate it better with the wireless stack.  And OLPC needs this
> > is not going to be an excuse of it's own.
> 
> The main feature of this chip is the on-chip support for 802.11s in
> firmware. What is the plan for integrating 802.11s into the existing
> wireless stacks? Does it make sense to do a softmac type 802.11s
> implementation first to figure out the right places to put the hooks
> for the 8388 hardware implementation?

I believe Javier Cordona (who will also be at the Linux Wireless Summit
this weekend) is going to do a d80211-based implementation alongside the
Libertas 8388 firmware and driver bits too.  802.11s networking in Linux
is still quite immature, and we need to get people interested in a
standard stack talking to each other.

Dan



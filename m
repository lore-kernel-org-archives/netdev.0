From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 12:59:58 -0500
Message-ID: <1169575198.2777.37.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
	 <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
	 <1169566914.3649.4.camel@johannes.berg>
	 <9e4733910701230818g13dc82a2kf0972b8543db449f@mail.gmail.com>
	 <1169571273.3649.12.camel@johannes.berg>
	 <9e4733910701230914t52b39f2dha00ddfcec22fd3bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Marcelo Tosatti <marcelo@kvack.org>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965260AbXAWSAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 13:00:19 -0500
To: Jon Smirl <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701230914t52b39f2dha00ddfcec22fd3bd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-23 at 12:14 -0500, Jon Smirl wrote:
> On 1/23/07, Johannes Berg <johannes@sipsolutions.net> wrote:
> > On Tue, 2007-01-23 at 11:18 -0500, Jon Smirl wrote:
> >
> > > Is the 802.11s Draft 1.0 spec publicly available yet? It is supposed
> > > to be making changes at the very lowest MAC layers. It will be hard to
> > > be compatible with that from user space.
> >
> > Good point, it's not possible to implement this without changes to the
> > MAC.
> >
> > > The software doesn't have to be written but there should be at least
> > > some design work done on how 11s should fit into the existing world
> > > for both a firmware and software implementation. I'd hate to see a
> > > different implementation for each vendor and another one for the
> > > software stack.
> >
> > Then we'll first have to find those vendors interested in actually
> > changing their MAC to allow .11s I guess.
> 
> I haven't seen the 11s spec, are devices with softmac implementations
> flexible enough to implement it or do they need firmware changes too?

I believe it needs to at least support 4 address frames, which usually
requires firmware changes on fullmac cards, but fully softmac cards
(atheros, broadcom) probably would not.

Dan



From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: batostr() function
Date: Tue, 08 May 2012 19:48:33 +0200
Message-ID: <1336499313.4320.4.camel@jlt3.sipsolutions.net>
References: <1336391383.4325.24.camel@jlt3.sipsolutions.net>
	 <CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ@mail.gmail.com>
	 <1336487108.4320.2.camel@jlt3.sipsolutions.net>
	 <20120508143011.GD29352@aemeltch-MOBL1>
	 <1336497532.29640.24.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>,
	David Herrmann <dh.herrmann@googlemail.com>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:41480 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab2EHRsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 13:48:36 -0400
In-Reply-To: <1336497532.29640.24.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-08 at 10:18 -0700, Joe Perches wrote:
> On Tue, 2012-05-08 at 17:30 +0300, Andrei Emeltchenko wrote:
> > On Tue, May 08, 2012 at 04:25:08PM +0200, Johannes Berg wrote:
> > > On Tue, 2012-05-08 at 15:30 +0200, David Herrmann wrote:
> > > > Hi Johannes
> > > > 
> > > > On Mon, May 7, 2012 at 1:49 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> > > > > Really? 2 static buffers that are used alternately based on a static
> > > > > variable? How can that possibly be thread-safe? That may work in very
> > > > > restricted scenarios, but ...
> > > > 
> > > > Looking at "git blame" it seems the whole function is still from
> > > > linux-2.4. Looks like no-one ever noticed. I've sent a patchset fixing
> > > > it, thanks.
> > > 
> > > I was thinking you could use %pM, but it seems BT addresses are stored
> > > the wrong way around for some reason ...
> > 
> > This looks like better idea then allocating buffers, we can use swap to
> > take care about "wrong order".
> 
> https://lkml.org/lkml/2010/12/3/358

Pretty much what I had in mind, thanks. Luis, you'll notice that this
will be a pain to backport in compat. :-)

johannes

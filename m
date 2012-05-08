From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: batostr() function
Date: Tue, 8 May 2012 17:30:12 +0300
Message-ID: <20120508143011.GD29352@aemeltch-MOBL1>
References: <1336391383.4325.24.camel@jlt3.sipsolutions.net>
 <CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ@mail.gmail.com>
 <1336487108.4320.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Herrmann <dh.herrmann@googlemail.com>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52191 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755408Ab2EHO3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 10:29:05 -0400
Content-Disposition: inline
In-Reply-To: <1336487108.4320.2.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 08, 2012 at 04:25:08PM +0200, Johannes Berg wrote:
> On Tue, 2012-05-08 at 15:30 +0200, David Herrmann wrote:
> > Hi Johannes
> > 
> > On Mon, May 7, 2012 at 1:49 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> > > Really? 2 static buffers that are used alternately based on a static
> > > variable? How can that possibly be thread-safe? That may work in very
> > > restricted scenarios, but ...
> > 
> > Looking at "git blame" it seems the whole function is still from
> > linux-2.4. Looks like no-one ever noticed. I've sent a patchset fixing
> > it, thanks.
> 
> I was thinking you could use %pM, but it seems BT addresses are stored
> the wrong way around for some reason ...

This looks like better idea then allocating buffers, we can use swap to
take care about "wrong order".

Best regards 
Andrei Emeltchenko 

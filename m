From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Generic netlink interface help
Date: Wed, 30 May 2007 23:45:08 +0200
Message-ID: <20070530214508.GT521@postel.suug.ch>
References: <84po8XY4.1179999810.5490870.samuel@sortiz.org> <1180024477.18003.11.camel@johannes.berg> <20070525221802.GO521@postel.suug.ch> <1180272296.3604.64.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Samuel Ortiz <samuel@sortiz.org>, giometti@enneenne.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37631 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755765AbXE3Vor convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 17:44:47 -0400
Content-Disposition: inline
In-Reply-To: <1180272296.3604.64.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2007-05-27 15:24
> On Sat, 2007-05-26 at 00:18 +0200, Thomas Graf wrote:
> 
> > This area is still work in progress but the basic idea is that
> > like in kernel context, the application defines its set of
> > commands and assigns message parsers for each command. 
> 
> Ok, but why? For when we get asynchronous events from the kernel?

I don't want to enforce a separate socket for every generic
netlink family.

> > For now,
> > the message parser is linked into the cache operations which
> > means that you have to "update" a cache in order to use this
> > feature. 
> 
> What's the cache good for to start with?
> 
> My current userland tool just send a message and expects back a
> response. Obviously that's broken once we have events too, is that when
> the message parsers come in?

See the documentation, a cache is basically a collection of
objects. For events, you'd probably want to have each event
added to a cache and then iterate over the cache to handle
the events in the right order.

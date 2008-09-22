From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 16:21:58 -0700 (PDT)
Message-ID: <20080922.162158.223213897.davem@davemloft.net>
References: <48D82378.4000306@redhat.com>
	<20080922.161323.108280715.davem@davemloft.net>
	<20080922232428.GA25711@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753779AbYIVXWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:22:10 -0400
In-Reply-To: <20080922232428.GA25711@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 23 Sep 2008 01:24:28 +0200

> On Mon, Sep 22, 2008 at 04:13:23PM -0700, David Miller wrote:
> > From: Chris Snook <csnook@redhat.com>
> > Date: Mon, 22 Sep 2008 19:00:08 -0400
> > 
> > > Could you please point me to an example of a connection parameter
> > > that gets tuned and cached this way, so I can experiment with it?
> > 
> > You'll find tons of them in tcp_update_metrics().
> 
> IMHO that is actually obsolete because it does not take NAT
> into account. One IP does not necessarily share link characteristics.

It is not an invalid estimate even in the NAT case, and it's not
so illegal like TCP timewait recycling would be.

Andi, don't rain on the party for something that might be terribly
useful for many people.

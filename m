From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 10 Mar 2009 10:34:59 +0100
Message-ID: <20090310093459.GJ4738@xi.wantstofly.org>
References: <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org> <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk> <49A97669.80309@mlbassoc.com> <Pine.LNX.4.64.0902282004340.9845@ask.diku.dk> <1235988885.30736.44.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Gary Thomas <gary@mlbassoc.com>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:45021 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbZCJJfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 05:35:02 -0400
Content-Disposition: inline
In-Reply-To: <1235988885.30736.44.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 11:14:45AM +0100, Jesper Dangaard Brouer wrote:

> > If you will send me the current patches/code, then I'll use some time 
> > monday to look at the register settings to see if I can spot the problem, 
> > by corrolating with my device driver.
> 
> Looking through my old code I found this comment, which indicate that
> you should take care of PPU (Phy Polling Unit) state... I had to support
> both the 6095 and 6097 chip.

PPU disabling/enabling should be handled by the current code already,
as it is also necessary for the 6131 (but not for the 6161/6165/etc).

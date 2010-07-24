From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [patch -next v2] mv643xx_eth: potential null dereference
Date: Sat, 24 Jul 2010 21:00:36 +0200
Message-ID: <20100724190036.GA21121@mail.wantstofly.org>
References: <20100723101528.GF26313@bicker> <1279881177.24768.1623.camel@Joe-Laptop.home> <20100723110504.GG26313@bicker> <4C49C39E.8020502@bfs.de> <20100723221514.GJ26313@bicker> <4C4AAB5B.2050901@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <error27@gmail.com>, Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Saeed Bishara <saeed@marvell.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:51349 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268Ab0GXTAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 15:00:38 -0400
Content-Disposition: inline
In-Reply-To: <4C4AAB5B.2050901@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 24, 2010 at 10:59:07AM +0200, walter harms wrote:

> IMHO it would be better to make sure that pd->t_clk,pd->tx_csum_limit
> have usefull values than adding a check but this is up to the maintainer.

I don't see the point of that at all.  We check against zero to see
whether the caller bothered to fill in the field at all, but if the
caller wants to pass in bogus values, that's up to the caller.

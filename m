From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 22:22:21 -0500
Message-ID: <1266463341.5719.96.camel@obelisk.thedillows.org>
References: <1266460221.5719.60.camel@obelisk.thedillows.org>
	 <20100217.184100.232538560.davem@davemloft.net>
	 <1266462064.5719.78.camel@obelisk.thedillows.org>
	 <20100217.191002.240804576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:54096 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177Ab0BRDWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 22:22:25 -0500
In-Reply-To: <20100217.191002.240804576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 19:10 -0800, David Miller wrote:
> > From: David Dillow <dave@thedillows.org>
> > Date: Wed, 17 Feb 2010 21:30:21 -0500
> > I liked it because it consistent with eth device naming when it could
> > be, and gave them useful info to go on when it failed during
> > initialization.
> 
> How can printing a PCI device name string be consistent with eth
> device naming?

I meant that once it had been probed and initialized, it used the eth
name, consistent with other network drivers. Prior to that, it gave as
much info as it could to identify the failing device.

> I already tossed his patch from my tree.

Ok, I'll continue to work with Joe to get this acceptable to all of us.
I really need to focus on paying work tonight, so this will have to wait
until the weekend, but we'll have a replacement to you by Monday.



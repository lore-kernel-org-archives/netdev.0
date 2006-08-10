From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event notifications
Date: Thu, 10 Aug 2006 21:04:55 +0200
Message-ID: <20060810190455.GI14627@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch> <20060809205440.025848027@postel.suug.ch> <44DB765B.4020500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55229 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932508AbWHJTEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 15:04:34 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44DB765B.4020500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-08-10 20:09
> Thomas Graf wrote:
> > Setting a socket error on all sockets subscribed to a group
> > if an event notificiation of said group fails due to memory
> > pressure only confuses applications and is of no use. 
> > 
> > This patch removes it all together.
> 
> I disagree with this patch, how else are applications supposed
> to know when they missed an update and are not in sync anymore?
> I actually have a half-finished patch to add this in some spots
> where its missing (and uses better error codes).

The application has no idea what went wrong nor does it know
for which group so it will have to resync all group subscrptions
and as it only happens due to memory pressure that will fail
anyway.

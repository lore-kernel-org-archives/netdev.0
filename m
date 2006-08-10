From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event
 notifications
Date: Thu, 10 Aug 2006 20:09:31 +0200
Message-ID: <44DB765B.4020500@trash.net>
References: <20060809204821.216122988@postel.suug.ch> <20060809205440.025848027@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:27861 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422683AbWHJSLa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 14:11:30 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060809205440.025848027@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Setting a socket error on all sockets subscribed to a group
> if an event notificiation of said group fails due to memory
> pressure only confuses applications and is of no use. 
> 
> This patch removes it all together.

I disagree with this patch, how else are applications supposed
to know when they missed an update and are not in sync anymore?
I actually have a half-finished patch to add this in some spots
where its missing (and uses better error codes).


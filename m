From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event notifications
Date: Thu, 10 Aug 2006 21:23:23 +0200
Message-ID: <20060810192323.GJ14627@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch> <20060809205440.025848027@postel.suug.ch> <44DB765B.4020500@trash.net> <20060810190455.GI14627@postel.suug.ch> <44DB8425.8020108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:18110 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751031AbWHJTXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 15:23:03 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44DB8425.8020108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-08-10 21:08
> The error code (-ENOMEM) gives it a pretty good idea what went
> wrong. Its true that it doesn't know which group was affected
> (that could be fixed), but at least it knows that something
> went wrong and it needs to resync. If that fails due to memory
> shortage as well it can schedule a delayed resync or something,
> but without getting notified it has no chance of doing anything
> useful. This makes notification essentially useless. If I can't
> rely on either getting either a notification or an error, I can't
> rely on them at all.
> 
> Please put this back in.

Alright, I think it's pretty much theoretical but it doesn't
really matter to me.

Dave, please revert the whole patchset.

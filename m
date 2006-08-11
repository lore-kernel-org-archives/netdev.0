From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event notifications
Date: Fri, 11 Aug 2006 12:38:22 +0200
Message-ID: <20060811103822.GN14627@postel.suug.ch>
References: <20060810190455.GI14627@postel.suug.ch> <44DB8425.8020108@trash.net> <20060810192323.GJ14627@postel.suug.ch> <20060810.230242.42459982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50129 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932075AbWHKKiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 06:38:04 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060810.230242.42459982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-08-10 23:02
> Thomas, there was a conflict which I did expect since I added
> all the 2.6.18 bug fixes into the tree.  The conflict is for
> your netlink conversion of the iflink stuff.
> 
> I had to fix the -stable tree IFLA_ADDRESS handling because
> dev->set_mac_address expects a sockaddr not a raw MAC
> address.
> 
> I think I resolved the conflict while applying the patch
> properly, but if you could take a look I'd appreciate it.

Looks good. You could have used nla_memcpy() instead of
memcpy() but there is no functional difference in this case.

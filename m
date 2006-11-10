From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NETLINK]: Do precise netlink message allocations where possible
Date: Fri, 10 Nov 2006 23:16:40 +0100
Message-ID: <20061110221640.GN8693@postel.suug.ch>
References: <20061110121706.GH8693@postel.suug.ch> <4554A2FE.2020405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42731 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1424443AbWKJWQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 17:16:19 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <4554A2FE.2020405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul Moore <paul.moore@hp.com> 2006-11-10 11:04
> I like this approach, it makes much more sense to me then the previous
> implementation which was a simple "alias" to alloc_skb().  Also, the NetLabel
> relevant sections look fine to me.

Question is wheter to do the same for genetlink and add genlmsg_new().
I'm currently thinking about this and also about some _reply() function
which takes a struct genl_info so a genetlink module doesn't have to
know about how to address the client by pid anymore.

Ideas or even patches very welcome.

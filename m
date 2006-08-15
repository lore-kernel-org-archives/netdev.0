From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 02:07:31 +0200
Message-ID: <20060815000730.GT14627@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch> <20060814214341.834971519@postel.suug.ch> <1155598991.6946.42.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37841 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965055AbWHOAHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 20:07:10 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155598991.6946.42.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-08-14 19:43
> On Mon, 2006-14-08 at 00:00 +0200, Thomas Graf wrote:
> > plain text document attachment (rtnl_convert_ip6_addr)
> > Fixes a wrong use of current->pid as netlink pid.
> 
> If i am not mistaken:
> Some of these removals of current->pid will affect users such as quagga,
> zebra, vrrpd etc. If those specific users are not affected, please
> ignore the rest of my comments.

I'm aware of that. The next patchset cleaning up fib6 and ifa6 will
provide means to pass on the required netlink information to these
notification functions.

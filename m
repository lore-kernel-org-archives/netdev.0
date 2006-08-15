From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Mon, 14 Aug 2006 20:12:49 -0400
Message-ID: <1155600769.6946.49.camel@jzny2>
References: <20060814213718.580598840@postel.suug.ch>
	 <20060814214341.834971519@postel.suug.ch> <1155598991.6946.42.camel@jzny2>
	 <20060815000730.GT14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:9444 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932753AbWHOAbW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 20:31:22 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GCmq8-0000Ux-QJ
	for netdev@vger.kernel.org; Mon, 14 Aug 2006 20:31:28 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060815000730.GT14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-15-08 at 02:07 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-08-14 19:43

> > If i am not mistaken:
> > Some of these removals of current->pid will affect users such as quagga,
> > zebra, vrrpd etc. If those specific users are not affected, please
> > ignore the rest of my comments.
> 
> I'm aware of that. The next patchset cleaning up fib6 and ifa6 will
> provide means to pass on the required netlink information to these
> notification functions.

Good nuf. Thanks Thomas.

cheers,
jamal


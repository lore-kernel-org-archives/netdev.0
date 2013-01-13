From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sun, 13 Jan 2013 08:35:45 -0800
Message-ID: <1358094945.8744.24.camel@edumazet-glaptop>
References: <50F1699E.1000200@hartkopp.net>
	 <20130112.132316.2121287993605534669.davem@davemloft.net>
	 <20130112.133630.257139657732337147.davem@davemloft.net>
	 <1358046374.20249.1789.camel@edumazet-glaptop>
	 <20130113035013.GJ5259@kvack.org>
	 <1358056199.20249.2121.camel@edumazet-glaptop>
	 <20130113145929.GK5259@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:38687 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab3AMQfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 11:35:48 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so1461277dam.18
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2013 08:35:47 -0800 (PST)
In-Reply-To: <20130113145929.GK5259@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-13 at 09:59 -0500, Benjamin LaHaise wrote:

> 
> The locking isn't the issue, but how the network namespace is selected it.  
> I've implemented some virtual router functionality using network namespaces, 
> and prior to having the setns() syscall, the only way to manipulate other 
> network namespaces was via socket passing between threads in different 
> namespaces.  One of the optimizations in using this technique was to open a 
> netlink socket in another namespace, then pass that file descriptor back to 
> the main daemon.  The code could then add routes and manipulate other areas 
> of the network stack via that netlink socket.
> 

OK thats evil, I'll pass the net pointer then.

Thanks

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Fri, 21 Sep 2012 18:51:21 +0200
Message-ID: <1348246281.2669.755.camel@edumazet-glaptop>
References: <505B773E.9070501@hp.com>
	 <1348172722.2669.10.camel@edumazet-glaptop>
	 <1348242511.2669.635.camel@edumazet-glaptop>
	 <20120921.122705.1344923255084267186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51830 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756456Ab2IUQv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 12:51:28 -0400
Received: by bkuw11 with SMTP id w11so932837bku.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 09:51:27 -0700 (PDT)
In-Reply-To: <20120921.122705.1344923255084267186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 12:27 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 21 Sep 2012 17:48:31 +0200
> 
> > There is probably a reason why lo default MTU is 16436 ?
> 
> That's what fit into L1 caches back in 1999

I see ;)

Nowadays, we even have the NETIF_F_NOCACHE_COPY flag and
__copy_from_user_nocache()

Hmm, we can not toggle this flag on loopback yet

# ethtool -K lo tx-nocache-copy on
Could not change any device features

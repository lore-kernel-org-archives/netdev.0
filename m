From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Thu, 3 May 2012 12:32:27 +0000
Message-ID: <201205031232.27842.arnd@arndb.de>
References: <1335765093.2296.4.camel@edumazet-glaptop> <1335941961.22133.48.camel@edumazet-glaptop> <20120503.022837.2021054007853235758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:54132 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915Ab2ECMcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 08:32:43 -0400
In-Reply-To: <20120503.022837.2021054007853235758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 May 2012, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 May 2012 08:59:21 +0200
> 
> > If Arnd doesnt care to even reply, we can just revert his buggy
> > patch, instead of trying to understand and fix all issues.
> 
> Agreed, it's the best sounding solution by far.

I've tried to understand what I've done back then but also couldn't
remember, so I won't complain when it gets reverted.

For all I know I did this because it looked broken back then, but
I don't remember a specific way in which it could be exploited
to escape a namespace.

	Arnd

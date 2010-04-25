From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sat, 24 Apr 2010 22:51:28 -0700 (PDT)
Message-ID: <20100424.225128.52181685.davem@davemloft.net>
References: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51519
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034Ab0DYFvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 01:51:23 -0400
In-Reply-To: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 24 Apr 2010 23:17:07 +0800

> optimize rps_get_cpu().
> 
> don't initialize ports when we can get the ports. one memory access for ports
> than two.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.

We can load both addresses in one go on 64-bit btw.

It seems we're just duplicating, one by one, the optimizations
we already do in INET_COMBINED_PORTS() and INET_ADDR_COOKIE().
:-)

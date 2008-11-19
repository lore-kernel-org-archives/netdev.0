From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make /proc/net/protocols namespace aware
Date: Wed, 19 Nov 2008 15:14:13 -0800 (PST)
Message-ID: <20081119.151413.237646291.davem@davemloft.net>
References: <49214D37.2090502@cosmosbay.com>
	<20081117111516.GA10542@x200.localdomain>
	<4921551B.4000102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, den@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46509
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752016AbYKSXON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:14:13 -0500
In-Reply-To: <4921551B.4000102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 12:27:23 +0100

> Good catch, thanks Alexey
> 
> [PATCH] net: make /proc/net/protocols namespace aware
> Converting /proc/net/protocols to be namespace aware is quite easy
> and permits us to use sock_prot_inuse_get().
> 
> This provides seperate counters for each protocol. For example
> we can really count TCPv6 sockets and TCPv4 sockets, while previously,
> we had the same value, and this value was not namespace aware.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6, thanks.

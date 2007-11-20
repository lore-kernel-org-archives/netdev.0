From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6 net-2.6.25] IPv4 RAW: Compact the API for the kernel
Date: Mon, 19 Nov 2007 22:35:22 -0800 (PST)
Message-ID: <20071119.223522.171514440.davem@davemloft.net>
References: <473DA3C7.4080201@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753639AbXKTGfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:35:22 -0500
In-Reply-To: <473DA3C7.4080201@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 16 Nov 2007 17:05:59 +0300

> The raw sockets functions are explicitly used from 
> inside the kernel in two places:
> 
> 1. in ip_local_deliver_finish to intercept skb-s
> 2. in icmp_error
> 
> For this purposes many functions and even data structures,
> that are naturally internal for raw protocol, are exported.
> 
> Compact the API to two functions and hide all the other
> (including hash table and rwlock) inside the net/ipv4/raw.c
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.

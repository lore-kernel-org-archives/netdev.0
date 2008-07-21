From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] netns: dont alloc ipv6 fib timer list
Date: Mon, 21 Jul 2008 13:26:01 -0700 (PDT)
Message-ID: <20080721.132601.62660580.davem@davemloft.net>
References: <20080721192834.221648982@vyatta.com>
	<20080721192920.058840619@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753140AbYGUU0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:26:01 -0400
In-Reply-To: <20080721192920.058840619@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jul 2008 12:28:36 -0700

> FIB timer list is a trivial size structure, avoid indirection and just
> put it in existing ns.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I don't see how this works only changing ip6_fib.c, isn't
there a header file change necessary to go along with
this?

In particular there needs to be some change to include/net/netns/ipv6.h

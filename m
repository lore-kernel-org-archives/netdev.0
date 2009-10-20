From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Mon, 19 Oct 2009 20:59:48 -0700 (PDT)
Message-ID: <20091019.205948.193706797.davem@davemloft.net>
References: <4ADC96D6.4000909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755843AbZJTD7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 23:59:25 -0400
In-Reply-To: <4ADC96D6.4000909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Oct 2009 18:41:58 +0200

> ipv4/ipv6 setsockopt(IP_MULTICAST_IF) have dubious __dev_get_by_index() calls.

Dubious, how so?

Yes, I know RTNL/dev_base_lock, but it's not using what it gets
back at all.

It's testing existence, a boolean, it doesn't dereference the
'dev' it gets back at all.

This code is intentional and perfectly fine.

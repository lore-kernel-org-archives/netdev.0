From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] ipv6: user better hash for addrconf
Date: Sat, 20 Mar 2010 16:05:46 -0700 (PDT)
Message-ID: <20100320.160546.68157320.davem@davemloft.net>
References: <20100318063108.109693694@vyatta.com>
	<20100318063123.092727548@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45317
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752615Ab0CTXFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 19:05:23 -0400
In-Reply-To: <20100318063123.092727548@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Mar 2010 23:31:12 -0700

> The existing hash function has a couple of issues:
>   * it is hardwired to 16 for IN6_ADDR_HSIZE
>   * limited to 256 and callers using int
>   * use jhash2 rather than some old BSD algorithm
> 
> No need for random seed since this is local only (based on assigned
> addresses) table.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

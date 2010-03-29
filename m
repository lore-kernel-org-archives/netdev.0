From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6: Don't drop cache route entry unless
 timer actually expired.
Date: Sun, 28 Mar 2010 19:34:42 -0700 (PDT)
Message-ID: <20100328.193442.21220010.davem@davemloft.net>
References: <201003281715.o2SHFjai004362@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, guenter.roeck@ericsson.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34836
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755731Ab0C2CeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 22:34:19 -0400
In-Reply-To: <201003281715.o2SHFjai004362@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 29 Mar 2010 02:15:45 +0900

> This is ipv6 variant of the commit 5e016cbf6.. ("ipv4: Don't drop
> redirected route cache entry unless PTMU actually expired")
> by Guenter Roeck <guenter.roeck@ericsson.com>.
> 
> Remove cache route entry in ipv6_negative_advice() only if
> the timer is expired.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks a lot!

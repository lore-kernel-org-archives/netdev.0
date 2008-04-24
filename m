From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.26 (Plan B)] [TCP]: Lower stack usage in
 tcp4_seq_show().
Date: Thu, 24 Apr 2008 01:02:36 -0700 (PDT)
Message-ID: <20080424.010236.189297164.davem@davemloft.net>
References: <20080415.193355.36907928.yoshfuji@linux-ipv6.org>
	<480DF7BE.5030803@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751127AbYDXICj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:02:39 -0400
In-Reply-To: <480DF7BE.5030803@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Apr 2008 18:35:42 +0400

> YOSHIFUJI Hideaki wrote:
> > tcp4_seq_show() eats about 250 bytes.  By using buffer in seq_file
> > directly, it will be reduced around 100 bytes.
> > 
> > One drawback is higher usage of slab for IPv6 but the format
> > will not change with this patch.
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Plan C: we can follow the Al Viro's proposal about %n like in this patch.
> The same applies to udp, fib (the /proc/net/route file), rt_cache and 
> sctp debug. This is minus ~150-200 bytes for each.
> 
> How do you think?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

To me, this looks great.  Thanks everyone for working on this.

Patch applied.

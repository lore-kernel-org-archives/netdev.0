From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] ROUTE: Make sending algorithm more friendly
 with RFC 4861.
Date: Sat, 19 Jan 2008 00:35:36 -0800 (PST)
Message-ID: <20080119.003536.60082707.davem@davemloft.net>
References: <20080119.020030.44981470.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52033
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbYASIfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 03:35:34 -0500
In-Reply-To: <20080119.020030.44981470.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sat, 19 Jan 2008 02:00:30 +0900 (JST)

> We omit (or delay) sending NSes for known-to-unreachable routers
> (in NUD_FAILED state) according to RFC 4191 (Default Router Preferences
> and More-Specific Routes).
> But this is not fully compatible with RFC 4861 (Neighbor Discovery Protocol
> for IPv6), which does not remember unreachability of neighbors.
> 
> So, let's avoid mixing sending algorithm of RFC 4191 and that of RFC 4861,
> and make the algorithm more friendly with RFC 4861 if RFC 4191 is disabled.
> 
> Issue was found by IPv6 Ready Logo Core Self_Test 1.5.0b2 (by TAHI Project),
> and has been tracked down by Mitsuru Chinen <mitch@linux.vnet.ibm.com>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6, thanks.

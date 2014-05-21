From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ip_tunnel: Initialize the fallback device
 properly
Date: Wed, 21 May 2014 02:09:27 -0400 (EDT)
Message-ID: <20140521.020927.1717803517104335619.davem@davemloft.net>
References: <20140519093656.GE32371@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pshelar@nicira.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaEUGJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 02:09:29 -0400
In-Reply-To: <20140519093656.GE32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 19 May 2014 11:36:56 +0200

> We need to initialize the fallback device to have a correct mtu
> set on this device. Otherwise the mtu is set to null and the device
> is unusable.
> 
> Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
> 
> v2: Add a reference to the commit that added the bug.
>     No code changes since v1.

Applied and queued up for -stable, thanks.

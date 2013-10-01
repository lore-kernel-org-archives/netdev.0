From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/4] ip_tunnel: Remove double unregister of the
 fallback device
Date: Tue, 01 Oct 2013 12:43:42 -0400 (EDT)
Message-ID: <20131001.124342.831094230856344763.davem@davemloft.net>
References: <20131001093359.GG7660@secunet.com>
	<20131001093737.GJ7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab3JAQnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:43:43 -0400
In-Reply-To: <20131001093737.GJ7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 1 Oct 2013 11:37:37 +0200

> When queueing the netdevices for removal, we queue the
> fallback device twice in ip_tunnel_destroy(). The first
> time when we queue all netdevices in the namespace and
> then again explicitly. Fix this by removing the explicit
> queueing of the fallback device.
> 
> Bug was introduced when network namespace support was added
> with commit 6c742e714d8 ("ipip: add x-netns support").
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.

Thanks!

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4/ip_gre: set transport header correctly to gre
 header
Date: Wed, 26 Dec 2012 15:20:25 -0800 (PST)
Message-ID: <20121226.152025.1719078076502235330.davem@davemloft.net>
References: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamahata@valinux.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab2LZXU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:20:26 -0500
In-Reply-To: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Dec 2012 11:51:03 +0900

> ipgre_tunnel_xmit() incorrectly sets transport header to inner payload
> instead of GRE header. It seems copy-and-pasted from ipip.c.
> So set transport header to gre header.
> (In ipip case the transport header is the inner ip header, so that's
> correct.)
> 
> Found by inspection. In practice the incorrect transport header
> doesn't matter because the skb usually is sent to another net_device
> or socket, so the transport header isn't referenced.
> 
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>

Applied.

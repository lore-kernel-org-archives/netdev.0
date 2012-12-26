From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6/ip6_gre: set transport header correctly
Date: Wed, 26 Dec 2012 15:20:31 -0800 (PST)
Message-ID: <20121226.152031.261734320140670444.davem@davemloft.net>
References: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
	<a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
	<8b3ad21951fd0ab05910ce5d4f4646142b18663a.1356403806.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamahata@valinux.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab2LZXUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:20:31 -0500
In-Reply-To: <8b3ad21951fd0ab05910ce5d4f4646142b18663a.1356403806.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Dec 2012 11:51:04 +0900

> ip6gre_xmit2() incorrectly sets transport header to inner payload
> instead of GRE header. It seems copy-and-pasted from ipip.c.
> Set transport header to gre header.
> (In ipip case the transport header is the inner ip header, so that's
> correct.)
> 
> Found by inspection. In practice the incorrect transport header
> doesn't matter because the skb usually is sent to another net_device
> or socket, so the transport header isn't referenced.
> 
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>

Applied.

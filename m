From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Reset secmark when scrubbing packet
Date: Wed, 24 Dec 2014 00:22:12 -0500 (EST)
Message-ID: <20141224.002212.1423065054989883755.davem@davemloft.net>
References: <efb09aca5173a9a18f15066c33a4998ed70bd34a.1419293504.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaLXFWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 00:22:14 -0500
In-Reply-To: <efb09aca5173a9a18f15066c33a4998ed70bd34a.1419293504.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 23 Dec 2014 01:13:18 +0100

> skb_scrub_packet() is called when a packet switches between a context
> such as between underlay and overlay, between namespaces, or between
> L3 subnets.
> 
> While we already scrub the packet mark, connection tracking entry,
> and cached destination, the security mark/context is left intact.
> 
> It seems wrong to inherit the security context of a packet when going
> from overlay to underlay or across forwarding paths.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied and queued up for -stable, thanks Thomas.

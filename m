From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: shrink struct softnet_data
Date: Mon, 03 Nov 2014 12:25:29 -0500 (EST)
Message-ID: <20141103.122529.1666622093277377387.davem@davemloft.net>
References: <1414936812.31792.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbaKCRZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:25:31 -0500
In-Reply-To: <1414936812.31792.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 Nov 2014 06:00:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> flow_limit in struct softnet_data is only read from local cpu
> and can be moved to fill a hole, reducing softnet_data size by
> 64 bytes on x86_64
> 
> While we are at it, move output_queue, output_queue_tailp and
> completion_queue, so that rx / tx paths touch a single cache line.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4: use one page fragment per incoming
 frame
Date: Tue, 04 Jun 2013 17:28:39 -0700 (PDT)
Message-ID: <20130604.172839.1461319576467138808.davem@davemloft.net>
References: <1370282095.24311.171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab3FEA2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:28:40 -0400
In-Reply-To: <1370282095.24311.171.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Jun 2013 10:54:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4 driver has a suboptimal memory allocation strategy for regular
> MTU=1500 frames, as it uses two page fragments :
> 
> One of 512 bytes and one of 1024 bytes.
> 
> This makes GRO less effective, as each GSO packet contains 8 MSS instead
> of 16 MSS.
> 
> Performance of a single TCP flow gains 25 % increase with the following
> patch.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

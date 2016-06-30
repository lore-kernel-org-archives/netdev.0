From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] tcp: increase size at which
 tcp_bound_to_half_wnd bounds to > TCP_MSS_DEFAULT
Date: Thu, 30 Jun 2016 08:19:16 -0400 (EDT)
Message-ID: <20160630.081916.1225181723655280381.davem@davemloft.net>
References: <CS1PR84MB0295BC70B8ACF200C11B5E25FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: shane.seymour@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbcF3MTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 08:19:42 -0400
In-Reply-To: <CS1PR84MB0295BC70B8ACF200C11B5E25FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Seymour, Shane M" <shane.seymour@hpe.com>
Date: Tue, 28 Jun 2016 23:06:48 +0000

> In previous commit 01f83d69844d307be2aa6fea88b0e8fe5cbdb2f4
> the following comments were added:
> 
> "When peer uses tiny windows, there is no use in packetizing to sub-MSS
> pieces for the sake of SWS or making sure there are enough packets in
> the pipe for fast recovery."
> 
> The test should be > TCP_MSS_DEFAULT not >= 512. This allows low end
> devices that send an MSS of 536 (TCP_MSS_DEFAULT) to see better network
> performance by sending it 536 bytes of data at a time instead of bounding
> to half window size (268). Other network stacks work this way, e.g. HP-UX.
> 
> Signed-off-by: Shane Seymour <shane.seymour@hpe.com>

Applied.

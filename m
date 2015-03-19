From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv4,ipv6: kill ip_mc_{join,leave}_group and
 ipv6_sock_mc_{join,drop}
Date: Wed, 18 Mar 2015 22:05:32 -0400 (EDT)
Message-ID: <20150318.220532.2249494989719491502.davem@davemloft.net>
References: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
	<4e10da321f4acaf728469dbebfe21416f7273356.1426700794.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbCSCFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:05:34 -0400
In-Reply-To: <4e10da321f4acaf728469dbebfe21416f7273356.1426700794.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 18 Mar 2015 14:50:43 -0300

> in favor of their inner __ ones, which doesn't grab rtnl.
> 
> As these functions need to operate on a locked socket, we can't be
> grabbing rtnl by then. It's too late and doing so causes reversed
> locking.
> 
> So this patch:
> - move rtnl handling to callers instead while already fixing some
>   reversed locking situations, like on vxlan and ipvs code.
> - renames __ ones to not have the __ mark:
>   __ip_mc_{join,leave}_group -> ip_mc_{join,leave}_group
>   __ipv6_sock_mc_{join,drop} -> ipv6_sock_mc_{join,drop}
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to net-next.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: invert join/leave anycast
 rtnl/socket locking order
Date: Fri, 20 Mar 2015 13:33:33 -0400 (EDT)
Message-ID: <20150320.133333.1652288836395343638.davem@davemloft.net>
References: <550C2DA0.6050809@cogentembedded.com>
	<1426862237-18597-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	sergei.shtylyov@cogentembedded.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbCTRdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:33:35 -0400
In-Reply-To: <1426862237-18597-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 20 Mar 2015 11:37:17 -0300

> Commit baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> missed to update two setsockopt options, IPV6_JOIN_ANYCAST and
> IPV6_LEAVE_ANYCAST, causing a lock inverstion regarding to the updated ones.
> 
> As ipv6_sock_ac_join and ipv6_sock_ac_leave are only called from
> do_ipv6_setsockopt, we are good to just move the rtnl lock upper.
> 
> Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> Reported-by: Ying Huang <ying.huang@intel.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thank you.

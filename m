From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net: allow setting mac address of loopback
 device
Date: Thu, 13 Feb 2014 17:47:13 -0500 (EST)
Message-ID: <20140213.174713.739120091193546605.davem@davemloft.net>
References: <1392168086-25607-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	nhorman@tuxdriver.com, stephen@networkplumber.org,
	edumazet@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbaBMWrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:47:16 -0500
In-Reply-To: <1392168086-25607-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Feb 2014 17:21:26 -0800

> We are trying to mirror the local traffic from lo to eth0,
> allowing setting mac address of lo to eth0 would make
> the ether addresses in these packets correct, so that
> we don't have to modify the ether header again.
> 
> Since usually no one cares about its mac address (all-zero),
> it is safe to allow those who care to set its mac address.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.

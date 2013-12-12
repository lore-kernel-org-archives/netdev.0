From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime
 state-changing behavior while valid_lft is infinity
Date: Thu, 12 Dec 2013 12:19:17 -0500 (EST)
Message-ID: <20131212.121917.1406764940497965422.davem@davemloft.net>
References: <20131212010348.GD4675@order.stressinduktion.org>
	<1386842500-2303-1-git-send-email-yasushi.asano@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yasushi.asano@jp.fujitsu.com
To: yazzep@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab3LLRTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 12:19:20 -0500
In-Reply-To: <1386842500-2303-1-git-send-email-yasushi.asano@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yazzep@gmail.com
Date: Thu, 12 Dec 2013 19:01:40 +0900

> From: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
> 
>  Fixed a problem with setting the lifetime of an IPv6
>  address. When setting preferred_lft to a value not zero or
>  infinity, while valid_lft is infinity(0xffffffff) preferred
>  lifetime is set to forever and does not update. Therefore
>  preferred lifetime never becomes deprecated. valid lifetime
>  and preferred lifetime should be set independently, even if
>  valid lifetime is infinity, preferred lifetime must expire
>  correctly (meaning it must eventually become deprecated)

Please do not indent your entire commit message with a leading space.

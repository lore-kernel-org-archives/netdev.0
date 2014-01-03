From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: fix preferred lifetime state-changing
 behavior while valid_lft is infinity
Date: Thu, 02 Jan 2014 19:35:09 -0500 (EST)
Message-ID: <20140102.193509.1856056053797832475.davem@davemloft.net>
References: <20131230021754.GA7718@order.stressinduktion.org>
	<1388459059-2563-1-git-send-email-yazzep@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yasushi.asano@jp.fujitsu.com
To: yazzep@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbaACAfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:35:10 -0500
In-Reply-To: <1388459059-2563-1-git-send-email-yazzep@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yasushi Asano <yazzep@gmail.com>
Date: Tue, 31 Dec 2013 12:04:19 +0900

> From: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
> 
> Fixed a problem with setting the lifetime of an IPv6
> address. When setting preferred_lft to a value not zero or
> infinity, while valid_lft is infinity(0xffffffff) preferred
> lifetime is set to forever and does not update. Therefore
> preferred lifetime never becomes deprecated. valid lifetime
> and preferred lifetime should be set independently, even if
> valid lifetime is infinity, preferred lifetime must expire
> correctly (meaning it must eventually become deprecated)
> 
> 
> Signed-off-by: Yasushi Asano <yasushi.asano@jp.fujitsu.com>

Applied.

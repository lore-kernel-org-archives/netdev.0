From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/1] ipv6: add support of ECMP
Date: Thu, 20 Sep 2012 17:15:25 -0400 (EDT)
Message-ID: <20120920.171525.2005584636029506440.davem@davemloft.net>
References: <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
	<1348046304-4156-1-git-send-email-nicolas.dichtel@6wind.com>
	<1348046304-4156-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bernat@luffy.cx, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755883Ab2ITVP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 17:15:28 -0400
In-Reply-To: <1348046304-4156-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 19 Sep 2012 11:18:24 +0200

> This patch adds the support of equal cost multipath for IPv6.
> 
> The patch is based on a previous work from
> Luc Saillard <luc.saillard@6wind.com>.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Please make the algorithm selection run-time rather than compile
time.

For %99.999999999999999999 of users, making compile time changes
to get the semantics they want is not an option.

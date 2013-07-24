From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6 eliminate parameter "int addrlen"
 in function fib6_add_1
Date: Wed, 24 Jul 2013 14:26:30 -0700 (PDT)
Message-ID: <20130724.142630.1684635689816423677.davem@davemloft.net>
References: <1374474069-22675-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jmorris@namei.org,
	hannes@stressinduktion.org, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab3GXV0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 17:26:31 -0400
In-Reply-To: <1374474069-22675-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Mon, 22 Jul 2013 14:21:09 +0800

> The "int addrlen" in fib6_add_1 is rebundant, as we can get it from
> parameter "struct in6_addr *addr" once we modified its type.
> And also fix some coding style issues in fib6_add_1
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Applied.

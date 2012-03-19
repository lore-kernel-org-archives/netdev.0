From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] ipv6: Allocate unique metrics for icmp6
 packets to prevent tainting dst metrics
Date: Mon, 19 Mar 2012 18:04:15 -0400 (EDT)
Message-ID: <20120319.180415.1274216814977167410.davem@davemloft.net>
References: <4F64B203.40307@network-box.com>
	<1332002201.19406.25.camel@edumazet-glaptop>
	<4F64CD4B.4070203@network-box.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nick.jones@network-box.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795Ab2CSWEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 18:04:24 -0400
In-Reply-To: <4F64CD4B.4070203@network-box.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Jones <nick.jones@network-box.com>
Date: Sun, 18 Mar 2012 01:43:39 +0800

> +		return ERR_CAST(-ENOMEM);

Really, please, stop wasting my time.  There is no way your compiler
didn't emit a warning for that garbage.

Furthermore, callers are only ready to handle NULL vs. non-NULL as
return values from this function.  So this return value you are adding
will result in crashes.

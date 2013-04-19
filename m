From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 16:53:11 -0400 (EDT)
Message-ID: <20130419.165311.2268390948739915560.davem@davemloft.net>
References: <1366403483.16391.59.camel@edumazet-glaptop>
	<20130419.163831.1434224426107133131.davem@davemloft.net>
	<20130419134925.4981bdfc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932474Ab3DSUxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:53:13 -0400
In-Reply-To: <20130419134925.4981bdfc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 Apr 2013 13:49:25 -0700

> The real problem is that DPDK and netmap can do multiple packets per request
> to driver.

And the kernel itself wouldn't benefit from batching support for
netdev_ops->ndo_start_xmit()?

Give me a break.

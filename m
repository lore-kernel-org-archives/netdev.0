From: David Miller <davem@davemloft.net>
Subject: Re: Traceroute and "ping" sockets: some questions
Date: Fri, 19 Aug 2011 04:38:16 -0700 (PDT)
Message-ID: <20110819.043816.1648681777223816477.davem@davemloft.net>
References: <4E4E46B4.9010909@odu.neva.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buc@odusz.so-cdu.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab1HSLiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 07:38:50 -0400
In-Reply-To: <4E4E46B4.9010909@odu.neva.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Date: Fri, 19 Aug 2011 15:19:16 +0400

> I would like to ask some questions:
> 
> - Currently such "ping" sockets implemented for IPv4 only. Are there any
> - plans to implement it for IPv6 as well?

I think the original authors of the kernel component said they would
work on this, but it hasn't materialized yet.

> - Are there any plans to implement some "rate control" (maybe
> - sysctl-configurable too), to restrict unprivileged users to send icmp
> - echoes too fast (ie. faster than 200 ms -- the current ping(8)
> - restriction)?

Why limit?  He can spam with UDP socket just as easily at any rate
he pleases, and rate limiting is policy issue and there relegated
to netfilter and/or the packet scheduler layer.

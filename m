From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] ipv6:introduce function to find route for redirect
Date: Thu, 05 Sep 2013 12:45:51 -0400 (EDT)
Message-ID: <20130905.124551.1242334240830454476.davem@davemloft.net>
References: <52271D15.1000806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab3IEQpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 12:45:53 -0400
In-Reply-To: <52271D15.1000806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 04 Sep 2013 19:44:21 +0800

> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> RFC 4861 says that the IP source address of the Redirect is the
> same as the current first-hop router for the specified ICMP
> Destination Address, so the gateway should be taken into
> consideration when we find the route for redirect.
> 
> There was once a check in commit
> a6279458c534d01ccc39498aba61c93083ee0372 ("NDISC: Search over
> all possible rules on receipt of redirect.") and the check
> went away in commit b94f1c0904da9b8bf031667afc48080ba7c3e8c9
> ("ipv6: Use icmpv6_notify() to propagate redirect, instead of
> rt6_redirect()").
> 
> The bug is only "exploitable" on layer-2 because the source
> address of the redirect is checked to be a valid link-local
> address but it makes spoofing a lot easier in the same L2
> domain nonetheless.
> 
> Thanks very much for Hannes's help.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied.

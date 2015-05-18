From: David Miller <davem@davemloft.net>
Subject: Re: [net-next fragmentation icmp v5 0/3] fragmentation ICMP
Date: Sun, 17 May 2015 23:48:33 -0400 (EDT)
Message-ID: <20150517.234833.1850042378148567219.davem@davemloft.net>
References: <1431724537-1919-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbERDsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:48:35 -0400
In-Reply-To: <1431724537-1919-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Fri, 15 May 2015 14:15:34 -0700

> Currently, we send ICMP packets when errors occur during fragmentation or
> de-fragmentation.  However, it is a bug when sending those ICMP packets
> in the context of using netfilter for bridging.
> 
> Those ICMP packets are only expected in the context of routing, not in
> bridging mode.
> 
> The local stack is not involved in bridging forward decisions, thus
> should be not used for deciding the reverse path for those ICMP messages.
> 
> This bug only affects IPV4, not in IPv6.

Series applied, thanks Andy.

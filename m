From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ila: ipv6/ila: fix nlsize calculation for
 lwtunnel
Date: Tue, 10 May 2016 16:01:11 -0400 (EDT)
Message-ID: <20160510.160111.2236118354201195551.davem@davemloft.net>
References: <20160501.193926.994161705403597197.davem@davemloft.net>
	<1462874192-8360-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbcEJUBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:01:18 -0400
In-Reply-To: <1462874192-8360-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 10 May 2016 11:56:32 +0200

> From: Tom Herbert <tom@herbertland.com>
> 
> The handler 'ila_fill_encap_info' adds two attributes: ILA_ATTR_LOCATOR
> and ILA_ATTR_CSUM_MODE.
> 
> nla_total_size_64bit() must be use for ILA_ATTR_LOCATOR.
> 
> Also, do nla_put_u8 instead of nla_put_u64 for ILA_ATTR_CSUM_MODE.
> 
> Fixes: f13a82d87b21 ("ipv6: use nla_put_u64_64bit()")
> Fixes: 90bfe662db13 ("ila: add checksum neutral ILA translations")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.

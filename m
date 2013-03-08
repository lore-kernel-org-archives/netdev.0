From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 2/4] ipv6: use newly introduced
 __ipv6_addr_needs_scope_id and ipv6_iface_scope_id
Date: Fri, 08 Mar 2013 12:29:58 -0500 (EST)
Message-ID: <20130308.122958.471371799078229531.davem@davemloft.net>
References: <20130308120719.GA5074@order.stressinduktion.org>
	<513A11E4.6040905@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088Ab3CHR37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:29:59 -0500
In-Reply-To: <513A11E4.6040905@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 09 Mar 2013 01:29:24 +0900

> Hannes Frederic Sowa wrote:
>> This patch requires multicast interface-scoped addresses to supply a
>> sin6_scope_id. Because the sin6_scope_id is now also correctly used
>> in case of interface-scoped multicast traffic this enables one to use
>> interface scoped addresses over interfaces which are not targeted by the
>> default multicast route (the route has to be put there manually, though).
>> 
>> getsockname() and getpeername() now return the correct sin6_scope_id in
>> case of interface-local mc addresses.
>> 
>> v2:
>> a) rebased ontop of patch 1/4 (now uses ipv6_addr_props)
>> 
>> v3:
>> a) reverted changes for ipv6_addr_props
>> 
>> v4:
>> a) unchanged
>> 
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
 ...
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>dave

Applied.

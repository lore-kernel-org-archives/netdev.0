From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/4] ipv6: introdcue
 __ipv6_addr_needs_scope_id and ipv6_iface_scope_id helper functions
Date: Fri, 08 Mar 2013 12:29:40 -0500 (EST)
Message-ID: <20130308.122940.1262031549529004950.davem@davemloft.net>
References: <20130308120716.GA5028@order.stressinduktion.org>
	<513A11C8.7050308@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088Ab3CHR3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:29:41 -0500
In-Reply-To: <513A11C8.7050308@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 09 Mar 2013 01:28:56 +0900

> Hannes Frederic Sowa wrote:
>> __ipv6_addr_needs_scope_id checks if an ipv6 address needs to supply
>> a 'sin6_scope_id != 0'. 'sin6_scope_id != 0' was enforced in case
>> of link-local addresses. To support interface-local multicast these
>> checks had to be enhanced and are now consolidated into these new helper
>> functions.
>> 
>> v2:
>> a) migrated to struct ipv6_addr_props
>> 
>> v3:
>> a) reverted changes for ipv6_addr_props
>> b) test for address type instead of comparing scope
>> 
>> v4:
>> a) unchanged
>> 
>> Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
...
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.

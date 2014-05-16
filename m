From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: update Destination Cache entries when gateway
 turn into host
Date: Thu, 15 May 2014 23:26:38 -0400 (EDT)
Message-ID: <20140515.232638.2142241060100428889.davem@davemloft.net>
References: <5374731E.3040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbaEPD0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:26:39 -0400
In-Reply-To: <5374731E.3040608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 15 May 2014 15:56:14 +0800

> 
> RFC 4861 states in 7.2.5:
> 
> 	The IsRouter flag in the cache entry MUST be set based on the
>          Router flag in the received advertisement.  In those cases
>          where the IsRouter flag changes from TRUE to FALSE as a result
>          of this update, the node MUST remove that router from the
>          Default Router List and update the Destination Cache entries
>          for all destinations using that neighbor as a router as
>          specified in Section 7.3.3.  This is needed to detect when a
>          node that is used as a router stops forwarding packets due to
>          being configured as a host.
> 
> Currently, when dealing with NA Message which IsRouter flag changes from
> TRUE to FALSE, the kernel only removes router from the Default Router List,
> and don't update the Destination Cache entries.
> 
> Now in order to update those Destination Cache entries, i introduce
> function rt6_clean_tohost().
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thank you.

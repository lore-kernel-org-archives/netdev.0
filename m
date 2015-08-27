From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fdb: rearrange net_bridge_fdb_entry
Date: Thu, 27 Aug 2015 16:39:09 -0700 (PDT)
Message-ID: <20150827.163909.1905886152046450354.davem@davemloft.net>
References: <1440710360-5390-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbbH0XjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:39:10 -0400
In-Reply-To: <1440710360-5390-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Thu, 27 Aug 2015 14:19:20 -0700

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> While looking into fixing the local entries scalability issue I noticed
> that the structure is badly arranged because vlan_id would fall in a
> second cache line while keeping rcu which is used only when deleting
> in the first, so re-arrange the structure and push rcu to the end so we
> can get 16 bytes which can be used for other fields (by pushing rcu
> fully in the second 64 byte chunk). With this change all the core
> necessary information when doing fdb lookups will be available in a
> single cache line.
 ...
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This looks fine, applied, thanks.

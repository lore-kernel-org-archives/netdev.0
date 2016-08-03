From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Remove incorrect WARN_ONCE().
Date: Wed, 03 Aug 2016 11:51:18 -0700 (PDT)
Message-ID: <20160803.115118.1798608087561999365.davem@davemloft.net>
References: <1470105367-46582-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbcHCSvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:51:19 -0400
In-Reply-To: <1470105367-46582-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Mon,  1 Aug 2016 19:36:07 -0700

> ovs_ct_find_existing() issues a warning if an existing conntrack entry
> classified as IP_CT_NEW is found, with the premise that this should
> not happen.  However, a newly confirmed, non-expected conntrack entry
> remains IP_CT_NEW as long as no reply direction traffic is seen.  This
> has resulted into somewhat confusing kernel log messages.  This patch
> removes this check and warning.
> 
> Fixes: 289f2253 ("openvswitch: Find existing conntrack entry after upcall.")
> Suggested-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied, thanks.

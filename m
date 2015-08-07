From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] bridge: netlink: account for the
 IFLA_BRPORT_PROXYARP attribute size and policy
Date: Thu, 06 Aug 2015 23:55:08 -0700 (PDT)
Message-ID: <20150806.235508.799001332675093580.davem@davemloft.net>
References: <1438707993-14561-1-git-send-email-razor@blackwall.org>
	<1438707993-14561-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, kyeyoonp@codeaurora.org,
	jouni@codeaurora.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbbHGGzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 02:55:09 -0400
In-Reply-To: <1438707993-14561-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue,  4 Aug 2015 19:06:32 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> The attribute size wasn't accounted for in the get_slave_size() callback
> (br_port_get_slave_size) when it was introduced, so fix it now. Also add
> a policy entry for it in br_port_policy.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: 958501163ddd ("bridge: Add support for IEEE 802.11 Proxy ARP")

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] vrf: vrf_master_ifindex_rcu is not always
 called with rcu read lock
Date: Tue, 18 Aug 2015 20:24:21 -0700 (PDT)
Message-ID: <20150818.202421.1780385295480410922.davem@davemloft.net>
References: <1439914666-7561-1-git-send-email-razor@blackwall.org>
	<1439923216-25295-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbbHSDYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 23:24:22 -0400
In-Reply-To: <1439923216-25295-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 18 Aug 2015 21:40:16 +0300

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> While running net-next I hit this:
 ...
> It would seem vrf_master_ifindex_rcu() can be called without RCU held in
> other contexts as well so introduce a new helper which acquires rcu and
> returns the ifindex.
> Also add curly braces around both the "if" and "else" parts as per the
> style guide.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v3: keep the rcu comment above vrf_master_ifindex_rcu()
> v2: use a new helper that acquires and releases rcu instead

Applied, thanks.

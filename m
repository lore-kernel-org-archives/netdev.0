From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Updates to netif_index_is_vrf
Date: Mon, 17 Aug 2015 15:56:54 -0700 (PDT)
Message-ID: <20150817.155654.769418515614784177.davem@davemloft.net>
References: <1439732960-3302-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbHQW4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 18:56:55 -0400
In-Reply-To: <1439732960-3302-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 16 Aug 2015 07:49:20 -0600

> As Eric noted netif_index_is_vrf is not called with rcu_read_lock held,
> so wrap the dev_get_by_index_rcu in rcu_read_lock and unlock.
> 
> If VRF is not enabled or oif is 0 skip the device lookup. In both cases
> index cannot be the VRF master.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2:
> - per Florian's suggestion keep the dev_get_by_index_rcu and wrap with
>   rcu_read_lock/unlock versus moving to dev_get_by_index with dev_hold/put

Applied, thanks.

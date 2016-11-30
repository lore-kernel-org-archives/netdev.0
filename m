From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix skb leak in IPv6 reassembly.
Date: Wed, 30 Nov 2016 11:02:30 -0500 (EST)
Message-ID: <20161130.110230.242891950781998057.davem@davemloft.net>
References: <20161128234353.4262-1-diproiettod@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, pshelar@ovn.org, joe@ovn.org
To: diproiettod@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757115AbcK3QCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:02:32 -0500
In-Reply-To: <20161128234353.4262-1-diproiettod@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Di Proietto <diproiettod@ovn.org>
Date: Mon, 28 Nov 2016 15:43:53 -0800

> If nf_ct_frag6_gather() returns an error other than -EINPROGRESS, it
> means that we still have a reference to the skb.  We should free it
> before returning from handle_fragments, as stated in the comment above.
> 
> Fixes: daaa7d647f81 ("netfilter: ipv6: avoid nf_iterate recursion")
> CC: Florian Westphal <fw@strlen.de>
> CC: Pravin B Shelar <pshelar@ovn.org>
> CC: Joe Stringer <joe@ovn.org>
> Signed-off-by: Daniele Di Proietto <diproiettod@ovn.org>

Applied, thanks.

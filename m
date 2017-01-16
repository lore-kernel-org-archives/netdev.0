From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] flow dissector: check if arp_eth is null rather
 than arp
Date: Mon, 16 Jan 2017 13:49:10 -0500 (EST)
Message-ID: <20170116.134910.2033399594368664910.davem@davemloft.net>
References: <20170113184820.823-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, jiri@mellanox.com, tom@herbertland.com,
        edumazet@google.com, hadarh@mellanox.com,
        simon.horman@netronome.com, fgao@ikuai8.com, amir@vadai.me,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdAPStM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:49:12 -0500
In-Reply-To: <20170113184820.823-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Fri, 13 Jan 2017 18:48:20 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> arp is being checked instead of arp_eth to see if the call to
> __skb_header_pointer failed. Fix this by checking arp_eth is
> null instead of arp.   Also fix to use length hlen rather than
> hlen - sizeof(_arp); thanks to Eric Dumazet for spotting
> this latter issue.
> 
> CoverityScan CID#1396428 ("Logically dead code") on 2nd
> arp comparison (which should be arp_eth instead).
> 
> Fixes: commit 55733350e5e8b70c5 ("flow disector: ARP support")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.

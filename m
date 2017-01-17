From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: sparse fixes in
 br_ip6_multicast_alloc_query()
Date: Tue, 17 Jan 2017 15:22:21 -0500 (EST)
Message-ID: <20170117.152221.526893269572042021.davem@davemloft.net>
References: <1484608295-24250-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdAQUXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:23:52 -0500
In-Reply-To: <1484608295-24250-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Mon, 16 Jan 2017 18:11:35 -0500

> Changed type of csum field in struct igmpv3_query from __be16 to
> __sum16 to eliminate type warning, made same change in struct
> igmpv3_report for consistency.
> 
> Fixed up an ntohs() where htons() should have been used instead.
> 
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied.

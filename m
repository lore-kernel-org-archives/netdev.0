From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] bonding: handle link transition from FAIL to UP
 correctly
Date: Thu, 13 Apr 2017 13:49:37 -0400 (EDT)
Message-ID: <20170413.134937.410754519019663582.davem@davemloft.net>
References: <20170412053600.35646-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753400AbdDMRtz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 13:49:55 -0400
In-Reply-To: <20170412053600.35646-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Tue, 11 Apr 2017 22:36:00 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> When link transitions from LINK_FAIL to LINK_UP, the commit phase is
> not called. This leads to an erroneous state causing slave-link state to
> get stuck in "going down" state while its speed and duplex are perfectly
> fine. This issue is a side-effect of splitting link-set into propose and
> commit phases introduced by de77ecd4ef02 ("bonding: improve link-status
> update in mii-monitoring")
> 
> This patch fixes these issues by calling commit phase whenever link
> state change is proposed.
> 
> Fixes: de77ecd4ef02 ("bonding: improve link-status update in mii-monitoring")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.

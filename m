From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] ipvlan: fix dev_id creation corner case.
Date: Mon, 16 Jan 2017 14:05:14 -0500 (EST)
Message-ID: <20170116.140514.1674761589594644492.davem@davemloft.net>
References: <20170113234830.16054-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, davem@davemloft.org,
        edumazet@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750855AbdAPTFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 14:05:16 -0500
In-Reply-To: <20170113234830.16054-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Fri, 13 Jan 2017 15:48:30 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> In the last patch da36e13cf65 ("ipvlan: improvise dev_id generation
> logic in IPvlan") I missed some part of Dave's suggestion and because
> of that the dev_id creation could fail in a corner case scenario. This
> would happen when more or less 64k devices have been already created and
> several have been deleted. If the devices that are still sticking around
> are the last n bits from the bitmap. So in this scenario even if lower
> bits are available, the dev_id search is so narrow that it always fails.
> 
> Fixes: da36e13cf65 ("ipvlan: improvise dev_id generation logic in IPvlan")
> CC: David Miller <davem@davemloft.org>
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.

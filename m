From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/ipv6: Correct PIM6 mrt_lock handling
Date: Sat, 05 Sep 2015 17:32:24 -0700 (PDT)
Message-ID: <20150905.173224.1142280299008389422.davem@davemloft.net>
References: <1441245151-11495-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
To: richard.laing@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbbIFAc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 20:32:28 -0400
In-Reply-To: <1441245151-11495-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Laing <richard.laing@alliedtelesis.co.nz>
Date: Thu,  3 Sep 2015 13:52:31 +1200

> In the IPv6 multicast routing code the mrt_lock was not being released
> correctly in the MFC iterator, as a result adding or deleting a MIF would
> cause a hang because the mrt_lock could not be acquired.
> 
> This fix is a copy of the code for the IPv4 case and ensures that the lock
> is released correctly.
> 
> Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks.

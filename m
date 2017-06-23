From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dp83640: Avoid NULL pointer dereference.
Date: Fri, 23 Jun 2017 14:38:46 -0400 (EDT)
Message-ID: <20170623.143846.888437777181372282.davem@davemloft.net>
References: <20170623155131.21427-1-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manfred.Rudigier@omicron.at,
        stefan.sorensen@spectralink.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbdFWSis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:38:48 -0400
In-Reply-To: <20170623155131.21427-1-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 23 Jun 2017 17:51:31 +0200

> The function, skb_complete_tx_timestamp(), used to allow passing in a
> NULL pointer for the time stamps, but that was changed in commit
> 62bccb8cdb69051b95a55ab0c489e3cab261c8ef ("net-timestamp: Make the
> clone operation stand-alone from phy timestamping"), and the existing
> call sites, all of which are in the dp83640 driver, were fixed up.
> 
> Even though the kernel-doc was subsequently updated in commit
> 7a76a021cd5a292be875fbc616daf03eab1e6996 ("net-timestamp: Update
> skb_complete_tx_timestamp comment"), still a bug fix from Manfred
> Rudigier came into the driver using the old semantics.  Probably
> Manfred derived that patch from an older kernel version.
> 
> This fix should be applied to the stable trees as well.
> 
> Fixes: 81e8f2e930fe ("net: dp83640: Fix tx timestamp overflow handling.")
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied and queued up for -stable, thank you.

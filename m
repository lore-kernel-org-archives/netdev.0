From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] bonding: fix string comparison errors
Date: Wed, 27 Jul 2011 22:41:25 -0700 (PDT)
Message-ID: <20110727.224125.1938418674068314841.davem@davemloft.net>
References: <1311714747-9407-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vitas@nppfactor.kiev.ua, fubar@us.ibm.com,
	tumeya@redhat.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754677Ab1G1Fll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:41:41 -0400
In-Reply-To: <1311714747-9407-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Tue, 26 Jul 2011 17:12:27 -0400

> When a bond contains a device where one name is the subset of another
> (eth1 and eth10, for example), one cannot properly set the primary
> device or the currently active device.
> 
> This was reported and based on work by Takuma Umeya.  I also verified
> the problem and tested that this fix resolves it.
> 
> V2: A few did not like the the current code or my changes, so I
> refactored bonding_store_primary and bonding_store_active_slave to be a
> bit cleaner, dropped the use of strnicmp since we did not really need
> the comparison to be case insensitive, and formatted the input string
> from sysfs so a comparison to IFNAMSIZ could be used.
> 
> I also discovered an error in bonding_store_active_slave that would
> modify bond->primary_slave rather than bond->curr_active_slave before
> forcing the bonding driver to choose a new active slave.
> 
> V3: Actually sending the proper patch....
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Reported-by: Takuma Umeya <tumeya@redhat.com>

Applied.

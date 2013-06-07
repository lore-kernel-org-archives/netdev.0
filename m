From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 5/6] bonding: Convert hw addr handling to
 sync/unsync, support ucast addresses
Date: Fri, 07 Jun 2013 15:06:21 -0700 (PDT)
Message-ID: <20130607.150621.1590078985676676844.davem@davemloft.net>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
	<1370037451-29466-6-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999Ab3FGWG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 18:06:26 -0400
In-Reply-To: <1370037451-29466-6-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 31 May 2013 14:57:30 -0700

> 	This patch converts bonding to use the dev_uc/mc_sync and
> dev_uc/mc_sync_multiple functions for updating the hardware addresses
> of bonding slaves.
> 
> 	The existing functions to add or remove addresses are removed,
> and their functionality is replaced with calls to dev_mc_sync or
> dev_mc_sync_multiple, depending upon the bonding mode.
> 
> 	Calls to dev_uc_sync and dev_uc_sync_multiple are also added,
> so that unicast addresses added to a bond will be properly synced with
> its slaves.
> 
> 	Various functions are renamed to better reflect the new
> situation, and relevant comments are updated.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied to net-next.

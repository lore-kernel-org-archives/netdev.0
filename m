From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gianfar: correctly determine the number of queue
 groups
Date: Thu, 05 Mar 2015 22:18:55 -0500 (EST)
Message-ID: <20150305.221855.83331066148017660.davem@davemloft.net>
References: <20150305134800.GA23653@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tobias@waldekranz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbCFDS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:18:57 -0500
In-Reply-To: <20150305134800.GA23653@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Waldekranz <tobias@waldekranz.com>
Date: Thu, 5 Mar 2015 14:48:23 +0100

> eTSEC of-nodes may have children which are not queue-group nodes. For
> example new-style fixed-phy declarations. These where incorrectly
> assumed to be additional queue-groups.
> 
> Change the search to filter out any nodes which are not queue-groups,
> or have been disabled.
> 
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>

Applied, thanks.

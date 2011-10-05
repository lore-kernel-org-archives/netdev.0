From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Add ethtool -g support to 8139cp
Date: Wed, 05 Oct 2011 17:53:29 -0400 (EDT)
Message-ID: <20111005.175329.2143609207723954863.davem@davemloft.net>
References: <20111005180854.3D68129003A8@tardy>
	<1317840648.2802.27.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raj@tardy.cup.hp.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934884Ab1JEVzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:55:33 -0400
In-Reply-To: <1317840648.2802.27.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 05 Oct 2011 19:50:48 +0100

> You generally don't need to set fields to zero in ethtool 'get'
> operations, as the ethtool core will initialise the entire structure to
> zero.

Rick, please remove the explicit zero initializations and resubmit,
thanks.

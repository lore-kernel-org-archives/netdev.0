From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] RPS: Ensure that an expired hardware filter
 can be re-added later
Date: Mon, 03 Oct 2011 12:14:54 -0400 (EDT)
Message-ID: <20111003.121454.1901988100913775562.davem@davemloft.net>
References: <1317652966.2847.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	amirv@dev.mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab1JCQPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 12:15:02 -0400
In-Reply-To: <1317652966.2847.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 03 Oct 2011 15:42:46 +0100

> Amir Vadai wrote:
>> When a stream is paused, and its rule is expired while it is paused,
>> no new rule will be configured to the HW when traffic resume.
> [...]
>> - When stream was resumed, traffic was steered again by RSS, and
>> because current-cpu was equal to desired-cpu,  ndo_rx_flow_steer
>> wasn't called and no rule was configured to the HW.
> 
> Fix this by setting the flow's current CPU only in the table for the
> newly selected RX queue.
> 
> Reported-and-tested-by: Amir Vadai <amirv@dev.mellanox.co.il>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.

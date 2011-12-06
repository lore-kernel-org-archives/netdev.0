From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Tue, 06 Dec 2011 00:41:21 -0500 (EST)
Message-ID: <20111206.004121.1820319056329214972.davem@davemloft.net>
References: <20111114.002630.2254622894958283155.davem@davemloft.net>
	<D789ECCE-08DE-4E6D-BCA7-2C54EC5758B7@kernel.crashing.org>
	<436A94C3-8F5B-4A8F-A46B-B66B503B98A0@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1LFFl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:41:27 -0500
In-Reply-To: <436A94C3-8F5B-4A8F-A46B-B66B503B98A0@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Mon, 5 Dec 2011 23:38:14 -0600

> Any comment on getting this patch pulled into net.git?

It requires a DT patch or related set of changes which have need
to be done differently as per feedback.

My understanding is there are two patches required, this revert plus
the changes to add the tbi property to the DT which are missing it.

That's why these tbi changes went in to begin with, to handle DT
which lack the property, or something like that.  So you can't
just revert this thing without also fixing the DT that lack the
tbi property, or else you break those systems.

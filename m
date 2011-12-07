From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Tue, 6 Dec 2011 23:35:31 -0600
Message-ID: <3FAC1EB0-2606-40BF-9BDF-8D2BCEB003E9@kernel.crashing.org>
References: <20111114.002630.2254622894958283155.davem@davemloft.net> <D789ECCE-08DE-4E6D-BCA7-2C54EC5758B7@kernel.crashing.org> <436A94C3-8F5B-4A8F-A46B-B66B503B98A0@kernel.crashing.org> <20111206.004121.1820319056329214972.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58924 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721Ab1LGFfb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 00:35:31 -0500
In-Reply-To: <20111206.004121.1820319056329214972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 5, 2011, at 11:41 PM, David Miller wrote:

> From: Kumar Gala <galak@kernel.crashing.org>
> Date: Mon, 5 Dec 2011 23:38:14 -0600
> 
>> Any comment on getting this patch pulled into net.git?
> 
> It requires a DT patch or related set of changes which have need
> to be done differently as per feedback.
> 
> My understanding is there are two patches required, this revert plus
> the changes to add the tbi property to the DT which are missing it.
> 
> That's why these tbi changes went in to begin with, to handle DT
> which lack the property, or something like that.  So you can't
> just revert this thing without also fixing the DT that lack the
> tbi property, or else you break those systems.

We need this patch in 3.2 regardless of DT.  Currently we get the oops on 3.2 on ALL systems.  Andy should be working up a device tree patch to fix the subset of .dts that are missing the tbi property.

What happens in 'next' is slightly different issue.

- k
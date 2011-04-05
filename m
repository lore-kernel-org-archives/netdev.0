From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 12/14] ehea: Add some more ethtool operations and 64bit
 stats
Date: Wed, 6 Apr 2011 07:35:36 +1000
Message-ID: <20110406073536.71f4052d@kryten>
References: <20110405212825.6eb85677@kryten>
	<20110405214249.36d248e7@kryten>
	<1302008877.2932.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	michael@ellerman.id.au
To: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51733 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755025Ab1DEVfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 17:35:39 -0400
In-Reply-To: <1302008877.2932.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Ben, Jesse,

> > We can use the standard ethtool functions for set_tx_csum and
> > set_sg.
> 
> These are deprecated.  Please use the generic features interface
> instead.
> 
> > Also switch to using ndo_get_stats64 to get 64bit tx/rx stats.

and

> Thank you for removing the old LRO code but the vlan-specific GRO
> entry point is deprecated as well so please don't add new uses of it.

Thanks for the suggestions, I'll incorporate the changes and resubmit.

Anton

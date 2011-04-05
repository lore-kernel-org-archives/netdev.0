From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 12/14] ehea: Add some more ethtool operations and 64bit
 stats
Date: Tue, 05 Apr 2011 14:07:57 +0100
Message-ID: <1302008877.2932.6.camel@bwh-desktop>
References: <20110405212825.6eb85677@kryten>
	 <20110405214249.36d248e7@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	michael@ellerman.id.au
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41043 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1DENIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 09:08:00 -0400
In-Reply-To: <20110405214249.36d248e7@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-05 at 21:42 +1000, Anton Blanchard wrote:
> We can use the standard ethtool functions for set_tx_csum and set_sg.

These are deprecated.  Please use the generic features interface
instead.

> Also switch to using ndo_get_stats64 to get 64bit tx/rx stats.
[...]

Should be a separate patch, really.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


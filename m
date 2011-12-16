From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] ethtool: Centralise validation of
 ETHTOOL_{G,S}RXFHINDIR parameters
Date: Fri, 16 Dec 2011 13:53:37 -0500 (EST)
Message-ID: <20111216.135337.67079945455480864.davem@davemloft.net>
References: <1323993076.2773.23.camel@bwh-desktop>
	<1323993301.2773.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	mcarlson@broadcom.com, eilong@broadcom.com, dm@chelsio.com,
	sbhatewara@vmware.com, pv-drivers@vmware.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932529Ab1LPSxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:53:45 -0500
In-Reply-To: <1323993301.2773.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 15 Dec 2011 23:55:01 +0000

> Add a new ethtool operation (get_rxfh_indir_size) to get the
> indirectional table size.  Use this to validate the user buffer size
> before calling get_rxfh_indir or set_rxfh_indir.  Use get_rxnfc to get
> the number of RX rings, and validate the contents of the new
> indirection table before calling set_rxfh_indir.  Remove this
> validation from drivers.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

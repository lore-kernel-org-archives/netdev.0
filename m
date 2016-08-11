From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macsec: use after free when deleting the
 underlying device
Date: Thu, 11 Aug 2016 09:59:13 -0700 (PDT)
Message-ID: <20160811.095913.971401938578495068.davem@davemloft.net>
References: <33fb7087b1e258144cc5d2ab155ecf11a8f410bb.1470921449.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbcHKQ7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 12:59:14 -0400
In-Reply-To: <33fb7087b1e258144cc5d2ab155ecf11a8f410bb.1470921449.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu, 11 Aug 2016 15:24:27 +0200

> macsec_notify() loops over the list of macsec devices configured on the
> underlying device when this device is being removed.  This list is part
> of the rx_handler data.
> 
> However, macsec_dellink unregisters the rx_handler and frees the
> rx_handler data when the last macsec device is removed from the
> underlying device.
> 
> Add macsec_common_dellink() to delete macsec devices without
> unregistering the rx_handler and freeing the associated data.
> 
> Fixes: 960d5848dbf1 ("macsec: fix memory leaks around rx_handler (un)registration")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.

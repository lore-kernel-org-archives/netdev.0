From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] Move Logitech Harmony 900 from cdc_ether to zaurus
Date: Wed, 22 Feb 2012 18:32:35 -0500 (EST)
Message-ID: <20120222.183235.162862240504650910.davem@davemloft.net>
References: <20120221230600.GA17347@bear.techie.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: talbert@techie.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745Ab2BVXco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 18:32:44 -0500
In-Reply-To: <20120221230600.GA17347@bear.techie.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Talbert <talbert@techie.net>
Date: Tue, 21 Feb 2012 18:06:00 -0500

> In the current kernel implementation, the Logitech Harmony 900 remote
> control is matched to the cdc_ether driver through the generic
> USB_CDC_SUBCLASS_MDLM entry.  However, this device appears to be of the
> pseudo-MDLM (Belcarra) type, rather than the standard one.  This patch
> blacklists the Harmony 900 from the cdc_ether driver and whitelists it for
> the pseudo-MDLM driver in zaurus.
> 
> Signed-off-by: Scott Talbert <talbert@techie.net>

Applied, thanks.

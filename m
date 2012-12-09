From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] caif_usb: Make the driver name check more
 efficient
Date: Sun, 09 Dec 2012 00:34:54 -0500 (EST)
Message-ID: <20121209.003454.640487870743353259.davem@davemloft.net>
References: <1354897227.2707.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab2LIFe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 00:34:56 -0500
In-Reply-To: <1354897227.2707.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 7 Dec 2012 16:20:27 +0000

> Use the device model to get just the name, rather than using the
> ethtool API to get all driver information.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Compile-tested only.  I'm assuming that the strncmp() is not really
> necessary, but perhaps there is some OOT variant of cdc_ncm that is also
> supposed to be supported?

Applied, I guess you found this while looking around for tests
of ethtool_ops being NULL?

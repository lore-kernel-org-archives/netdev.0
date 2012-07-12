From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/11] sfc: Implement 128-bit writes for
 efx_writeo_page
Date: Thu, 12 Jul 2012 08:13:00 -0700 (PDT)
Message-ID: <20120712.081300.624240435828585132.davem@davemloft.net>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
	<1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932679Ab2GLPNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:13:01 -0400
In-Reply-To: <1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 12 Jul 2012 00:15:18 +0100

> Add support for writing a TX descriptor to the NIC in one PCIe
> transaction on x86_64 machines.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

This absolutely does not belong in a driver.

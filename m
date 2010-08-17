From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Provide a default implementation of
 ethtool_ops::get_drvinfo
Date: Tue, 17 Aug 2010 01:50:24 -0700 (PDT)
Message-ID: <20100817.015024.245415197.davem@davemloft.net>
References: <1280980041.13192.628.camel@localhost>
	<20100804.215424.200345652.davem@davemloft.net>
	<1281036008.2095.6.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, mst@redhat.com,
	izumi.taku@jp.fujitsu.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756879Ab0HQIuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 04:50:06 -0400
In-Reply-To: <1281036008.2095.6.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 05 Aug 2010 20:20:08 +0100

> The driver name and bus address for a net_device can normally be found
> through the driver model now.  Instead of requiring drivers to provide
> this information redundantly through the ethtool_ops::get_drvinfo
> operation, use the driver model to do so if the driver does not define
> the operation.  Since ETHTOOL_GDRVINFO no longer requires the driver
> to implement any operations, do not require net_device::ethtool_ops to
> be set either.
> 
> Remove implementations of get_drvinfo and ethtool_ops that provide
> only this information.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor data
Date: Mon, 25 Jun 2012 15:24:15 -0700 (PDT)
Message-ID: <20120625.152415.1985101362538440728.davem@davemloft.net>
References: <1340463729.6345.25.camel@deadeye.wl.decadent.org.uk>
	<1340658258.4344.43.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1340659554.2572.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org, nsujir@broadcom.com,
	mcarlson@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756672Ab2FYWYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 18:24:17 -0400
In-Reply-To: <1340659554.2572.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 25 Jun 2012 22:25:54 +0100

> On Mon, 2012-06-25 at 14:04 -0700, Michael Chan wrote:
>> And please elaborate on the private ioctl.
> 
> Every driver gets to handle SIOCDEVPRIVATE .. SIOCDEVPRIVATE+15.  But
> avoid the first 3, as userland may blindly try to use them for MDIO.
> David may of course tell you that you should under no circumstances
> actually do this.

Indeed. :-)

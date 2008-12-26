From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] sfc: If AN is enabled, always read speed/duplex
 from the AN advertising bits
Date: Fri, 26 Dec 2008 13:49:33 -0800 (PST)
Message-ID: <20081226.134933.97120263.davem@davemloft.net>
References: <1230176613.3401.54.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752814AbYLZVta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 16:49:30 -0500
In-Reply-To: <1230176613.3401.54.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 25 Dec 2008 03:43:33 +0000

> When AN is enabled and the link is down the speed/duplex control bits
> will not be meaningful.  Use the advertising bits instead, and mask
> them with the LPA bits if and only if AN is complete (as before).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

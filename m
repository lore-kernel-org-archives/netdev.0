From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ks8695net: Disable non-working ethtool operations
Date: Thu, 13 Jan 2011 21:50:42 -0800 (PST)
Message-ID: <20110113.215042.200774287.davem@davemloft.net>
References: <1294941014.3946.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: figo1802@gmail.com, zealcook@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49951
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756897Ab1ANFuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:50:10 -0500
In-Reply-To: <1294941014.3946.46.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 13 Jan 2011 17:50:14 +0000

> Some ethtool operations can only be implemented for the WAN port, and
> not all such operations are allowed to return an error code such as
> -EOPNOTSUPP.  Therefore, define two separate ethtool_ops structures
> for WAN and non-WAN ports; simplify and rename the WAN-only functions.
> 
> This is completely untested as I don't have an ARM build environment.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
